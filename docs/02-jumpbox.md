# Set Up The Jumpbox

In this lab we will set up one of the four machines to be a `jumpbox`. This machine will be used to run commands throughout this tutorial.

Think of the `jumpbox` as the administration machine that you will use as a home base when setting up your Kubernetes cluster from the ground up. Before we get started we need to install a few command line utilities and clone the Kubernetes The Hard Way git repository, which contains some additional configuration files that will be used to configure various Kubernetes components throughout this tutorial.

Log in to the `jumpbox`:

```bash
ssh cowboy@jumpbox
```

All commands will be run as the `cowboy` user, which is part of wheel group and thus has the superuser rights. 

### Install Command Line Utilities

Now that you are logged into the `jumpbox` machine as the `cowboy` user, you will install the command line utilities that will be used to preform various tasks throughout the tutorial.

### Install Command Line Utilities
```bash
sudo emerge --sync
sudo emerge --ask \
  net-misc/wget \
  net-misc/curl \
  app-editors/vim \
  dev-libs/openssl \
  dev-vcs/git
```

### Sync GitHub Repository

Now it's time to download a copy of this tutorial which contains the configuration files and templates that will be used build your Kubernetes cluster from the ground up. Clone the Kubernetes The Hard Way git repository using the `git` command:

```bash
git clone https://github.com/mrmac189/KTHW.git
```

```bash
cd KTHW
```

### Download Binaries

In this section we will download the binaries for the Kubernetes components. The binaries will be stored in the `downloads` directory on the `jumpbox`, which will reduce the amount of internet bandwidth required as we avoid downloading the binaries multiple times for each machine in our Kubernetes cluster.

```bash
wget -q --show-progress \
  --https-only \
  --timestamping \
  -P downloads \
  -i downloads-amd64.txt
```

Once the download is complete, we can list them using the `ls` command:

```bash
ls -oh downloads
```

Extract the component binaries from the release archives and organize them under the `downloads` directory.

```bash
{
  ARCH=amd64
  mkdir -p downloads/{client,cni-plugins,controller,worker}
  tar -xvf downloads/crictl-v1.32.0-linux-${ARCH}.tar.gz \
    -C downloads/worker/
  tar -xvf downloads/containerd-2.1.0-beta.0-linux-${ARCH}.tar.gz \
    --strip-components 1 \
    -C downloads/worker/
  tar -xvf downloads/cni-plugins-linux-${ARCH}-v1.6.2.tgz \
    -C downloads/cni-plugins/
  tar -xvf downloads/etcd-v3.6.0-rc.3-linux-${ARCH}.tar.gz \
    -C downloads/ \
    --strip-components 1 \
    etcd-v3.6.0-rc.3-linux-${ARCH}/etcdctl \
    etcd-v3.6.0-rc.3-linux-${ARCH}/etcd
  mv downloads/{etcdctl,kubectl} downloads/client/
  mv downloads/{etcd,kube-apiserver,kube-controller-manager,kube-scheduler} \
    downloads/controller/
  mv downloads/{kubelet,kube-proxy} downloads/worker/
  mv downloads/runc.${ARCH} downloads/worker/runc
}
```

```bash
rm -rf downloads/*gz
```

Make the binaries executable.

```bash
{
  chmod +x downloads/{client,cni-plugins,controller,worker}/*
}
```

### Install kubectl

In this section you will install the `kubectl`, the official Kubernetes client command line tool, on the `jumpbox` machine. `kubectl` will be used to interact with the Kubernetes control plane once your cluster is provisioned later in this tutorial.

Use the `chmod` command to make the `kubectl` binary executable and move it to the `/usr/local/bin/` directory:

```bash
{
  cp downloads/client/kubectl /usr/local/bin/
}
```

At this point `kubectl` is installed and can be verified by running the `kubectl` command:

```bash
kubectl version --client
```

```text
Client Version: v1.32.3
Kustomize Version: v5.5.0
```

At this point the `jumpbox` has been set up with all the command line tools and utilities necessary to complete the labs in this tutorial.

Next: [Provisioning Compute Resources](03-compute-resources.md)
