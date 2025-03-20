# Linode Kubernetes Nodebalancer NotStarting When ID Specified

This is a demonstration of Linode being unable to start a NodeBalancer when the
ID is specified.

## Prerequisites

1. kubectl installed

## Steps to reproduce

1. Create a Linode LKE cluster
2. Download the kubeconfig file once ready
3. Run the following command to create a simple application with a NodeBalancer:

```
./setup.sh <kubeconfig file>
```
