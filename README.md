# Kubernetes a bit more harder Way
The original tutorial walks you through setting up [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way).  

This repo is my personal journey through KTHW, where I wanted some extra spice by using Gentoo as the main distro throughout the guide, thus the "a bit harder" way. 


## Cluster Details
Kubernetes a bit Harder Way guides you through bootstrapping a basic Kubernetes cluster with all control plane components running on a single node and two worker nodes.

Component versions:

* [kubernetes](https://github.com/kubernetes/kubernetes) v1.32.x
* [containerd](https://github.com/containerd/containerd) v2.1.x
* [cni](https://github.com/containernetworking/cni) v1.6.x
* [etcd](https://github.com/etcd-io/etcd) v3.6.x

## Labs

This tutorial requires four AMD64 based virtual or physical machines connected to the same network.

- [x] [Prerequisites](docs/01-prerequisites.md)
- [x] [Setting up the Jumpbox](docs/02-jumpbox.md)
- [x] [Provisioning Compute Resources](docs/03-compute-resources.md)
- [x] [Provisioning the CA and Generating TLS Certificates](docs/04-certificate-authority.md)
- [x] [Generating Kubernetes Configuration Files for Authentication](docs/05-kubernetes-configuration-files.md)
- [x] [Generating the Data Encryption Config and Key](docs/06-data-encryption-keys.md)
- [x] [Bootstrapping the etcd Cluster](docs/07-bootstrapping-etcd.md)
- [x] [Bootstrapping the Kubernetes Control Plane](docs/08-bootstrapping-kubernetes-controllers.md)
- [x] [Bootstrapping the Kubernetes Worker Nodes](docs/09-bootstrapping-kubernetes-workers.md)
- [x] [Configuring kubectl for Remote Access](docs/10-configuring-kubectl.md)
- [x] [Provisioning Pod Network Routes](docs/11-pod-network-routes.md)
- [x] [Smoke Test](docs/12-smoke-test.md)
- [x] [Cleaning Up](docs/13-cleanup.md)

## Copyright

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
