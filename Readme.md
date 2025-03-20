# Linode Kubernetes Nodebalancer NotStarting When ID Specified

This is a demonstration of Linode being unable to start a NodeBalancer when the
ID is specified.

## Prerequisites

1. kubectl installed
2. A domain name that you can manage

## Steps to reproduce

1. Create a Linode LKE cluster
2. Download the kubeconfig file once ready
3. Run the following command to create a simple application with a NodeBalancer:

```
./setup.sh <kubeconfig file> <domain name>
```

Once complete, check the IP address of the service via the Linode Web Console
and set it as an A record to your domain name.

This branch demonstrates that the external IP presented when the loadbalancer
service printed is wrong.

Use the command `kubectl get service -n nginx-ingress my-load-balancer` to print
the external IP.

It has the form of `172-233-103-117.ip.linodeusercontent.com` instead of
`172.233.103.117`

The problem is caused by the annotation:
service.beta.kubernetes.io/linode-loadbalancer-hostname-only-ingress: "true" ,
which, as explained in the
[LKE Load Balancing article](https://techdocs.akamai.com/cloud-computing/docs/get-started-with-load-balancing-on-an-lke-cluster).

> Annotation Suffix: hostname-only-ingress

> Values: Boolean

> Default Value: false

> Description: When true, the LoadBalancerStatus for the service will only
> contain the Hostname. This is useful for bypassing kube-proxy's rerouting of
> in-cluster requests originally intended for the external LoadBalancer to the
> service's constituent Pod IP addresses.
