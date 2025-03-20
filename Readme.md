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

In this branch, the kubernetes loadbalancer service does not start at all. It
stays at a pending state. All we do is set a nodebalancer id as described in the
[LKE Load Balancing article](https://techdocs.akamai.com/cloud-computing/docs/get-started-with-load-balancing-on-an-lke-cluster).

> Annotation Suffix: nodebalancer-id

> Values: String

> Default Value: None

> Description: The ID of the NodeBalancer to front the service. When not
> specified, a new NodeBalancer will be created. This can be configured on
> service creation or patching.

Checking the Linode Web Console, the NodeBalancer is not created at all.
