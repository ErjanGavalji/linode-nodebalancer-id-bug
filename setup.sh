#!/usr/bin/env bash

kubeConfig=$1
domainName=$2

if [ -z "${kubeConfig}" ]; then
	echo "Usage: $0 <kubeconfig> <domain-name>"
	exit 1
fi

if [ ! -f "${kubeConfig}" ]; then
	echo "Kubeconfig file not found: ${kubeConfig}"
	echo "Usage: $0 <kubeconfig> <domain-name>"
	exit 1
fi

if [ -z "${domainName}" ]; then
	echo "Usage: $0 <kubeconfig> <domain-name>"
	exit 1
fi

sedCmd="sed"
if [ "$(uname)" == "Darwin" ]; then
	sedCmd="gsed"
	if ! which gsed &> /dev/null; then
		echo "GNU sed is required for macOS. Install it using 'brew install gnu-sed'"
		exit 1
	fi
fi

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ingressSrcDir="${scriptDir}/lib/ingress"
ingressRepoUrl="git@github.com:nginxinc/kubernetes-ingress.git"
ingressBranchName="release-4.0"

#===================================================================================================
export KUBECONFIG=${kubeConfig}

echo "Ensuring the ingress repo..."
if [ ! -d "${ingressSrcDir}" ]; then
	git clone ${ingressRepoUrl} ${ingressSrcDir} -b ${ingressBranchName}
else
	(cd ${ingressSrcDir} && git clean -f -d && git checkout ${ingressBranchName} && git pull --rebase)
fi

kubectl apply -f ./namespaces.yml

#Base Ingress:
ingressDeploymentsPath=${ingressSrcDir}/deployments
kubectl apply -f ${ingressDeploymentsPath}/common/ns-and-sa.yaml
kubectl apply -f ${ingressDeploymentsPath}/rbac/rbac.yaml
kubectl apply -f ${ingressSrcDir}/examples/shared-examples/default-server-secret/default-server-secret.yaml
kubectl apply -f ${ingressDeploymentsPath}/common/nginx-config.yaml
kubectl apply -f ${ingressDeploymentsPath}/common/ingress-class.yaml
kubectl apply -f ${ingressSrcDir}/config/crd/bases/k8s.nginx.org_virtualservers.yaml
kubectl apply -f ${ingressSrcDir}/config/crd/bases/k8s.nginx.org_virtualserverroutes.yaml
kubectl apply -f ${ingressSrcDir}/config/crd/bases/k8s.nginx.org_transportservers.yaml
kubectl apply -f ${ingressSrcDir}/config/crd/bases/k8s.nginx.org_policies.yaml
kubectl apply -f ${ingressDeploymentsPath}/daemon-set/nginx-ingress.yaml

# Our ingress   
kubectl apply -f ./nginx-config.yml

kubectl apply -f ./app.yml

# Cert Manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml

# Wait for the cert-manager-webhook pod to be running:
echo "Waiting for cert-manager-webhook pod to be running... (will timeout in 5 minutes if unsuccessful)"
sleep 30
kubectl wait --for=condition=Ready pod -l app=webhook -n cert-manager --timeout=300s

# Wait a bit more:
sleep 30

kubectl apply -f ./staging-issuer.yml
kubectl apply -f ./prod-issuer.yml

# Replace the %#DOMAINNAME#% entry in the my-ingress.yml.template file with the domain name and appy:
cat ${scriptDir}/my-ingress.yml.template | ${sedCmd} "s|%#DOMAINNAME#%|${domainName}|g" | kubectl apply -f -

kubectl apply -f ${scriptDir}/load_balancer.yml

