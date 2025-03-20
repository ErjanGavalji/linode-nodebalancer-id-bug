#!/usr/bin/env bash

kubeConfig=$1
if [ -z "${kubeConfig}" ]; then
	echo "Usage: $0 <kubeconfig>"
	exit 1
fi

if [ ! -f "${kubeConfig}" ]; then
	echo "File not found: ${kubeConfig}"
	echo "Usage: $0 <kubeconfig>"
	exit 1
fi

#==============================================================================


export KUBECONFIG=${kubeConfig}
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
sleep 60
kubectl delete -f ./app.yml
sleep 60
kubectl delete namespace cert-manager
sleep 15
kubectl delete namespace nginx-ingress
sleep 15
kubectl delete namespace main-app
