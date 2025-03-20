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

function show_progress() {
	total=$1
	if [ -z "${total}" ]; then
		total=10
	fi
	time=$2
	if [ -z "${time}" ]; then
		time=3
	fi
	for i in $(seq 1 ${total}); do
		dots=$(printf '.%.0s' $(seq 1 $i))
		echo -ne "\r${dots} ${i}/${total}"
		sleep ${time}
	done
	echo ""
}

#==============================================================================


export KUBECONFIG=${kubeConfig}
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
show_progress 60
kubectl delete -f ./app.yml
show_progress 60
kubectl delete namespace cert-manager
show_progress 15
kubectl delete namespace nginx-ingress
show_progress 15
kubectl delete namespace main-app
