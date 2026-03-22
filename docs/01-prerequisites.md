# Prerequisites

In this lab you will review the machine requirements necessary to follow this tutorial.

## Virtual Machines

This tutorial requires four (4) virtual AMD64 machines running Gentoo. The following table lists the four machines and their CPU, memory, and storage requirements.

| Name    | Description            | CPU | RAM   | Storage |
|---------|------------------------|-----|-------|---------|
| jumpbox | Administration host    | 1   | 2GB   | 20GB    |
| server  | Kubernetes server      | 1   | 2GB   | 20GB    |
| node-0  | Kubernetes worker node | 1   | 2GB   | 20GB    |
| node-1  | Kubernetes worker node | 1   | 2GB   | 20GB    |

## Host system
My system is Gentoo host, running QEMU/libvirt. The following guides should be referenced to install the hypervisor platform:
- https://wiki.gentoo.org/wiki/Libvirt
- https://wiki.gentoo.org/wiki/Qemu
- https://wiki.gentoo.org/wiki/Virt-manager

Following Portage USE-Flags are used:

/etc/portage/package.use/libvirt
```bash
app-emulation/libvirt pcap virt-network numa fuse macvtap vepa qemu libssh2 bash-completion libvirtd
```

/etc/portage/package.use/qemu
```bash
app-emulation/qemu usbredir spice wayland virtfs doc QEMU_SOFTMMU_TARGETS: x86_64 QEMU_USER_TARGETS: x86_64
```

/etc/portage/package.use/virt-manager 
```bash
app-emulation/virt-manager gui
```

If libvirt can not activate the vnet, following kernel parameters may be need to be added: 
- NF_TABLES
- NF_NAT
- NF_CONNTRACK
- NFT_NAT
- NFT_MASQ
- NFT_CT

## Guest systems provisioning
To make guest VMs setup less mouse-clicky, I am going to use Terraform to provision the 4 VMs, by using the https://github.com/dmacvicar/terraform-provider-libvirt module. 

Gentoo has nowadays the cloud-init qcow2 images - https://www.gentoo.org/news/2025/02/20/gentoo-qcow2-images.html. We could use them direct to keep the guests installation simpler.

Before using the Terraform, one may need to test the virtualisation platform and having all the modules in kernel installed. I set a test VM up with virt-manager, using "no root pw" qcow2 image.
- QCOW2 image supports exclusively UEFI, that must be configured direct during the setup.

```xml
<os firmware="efi">
   <type arch="x86_64" machine="pc-q35-10.2">hvm</type>
   <firmware>
     <feature enabled="no" name="enrolled-keys"/>
     <feature enabled="no" name="secure-boot"/>
   </firmware>
   <loader readonly="yes" type="pflash" format="qcow2">/usr/share/edk2/OvmfX64/OVMF_CODE_4M.qcow2</loader>
```

After the correct functionality of VM is determined, the test VM can be deleted und it may be proceeded the approach with Terraform. 

- libvirtd daemon is the only method supported by dmacvicar/terraform-provider-libvirt, new modular architecture seems to not be supported (I needed to disable virt*d services and enable libvirtd)

After setting TFVars (rename the example to terraform.tfvars):

```sh
terraform apply
```

```sh
virsh list --all
```

4 VMs should be there. To look IPs: 

```sh
virsh domifaddr jumpbox
virsh domifaddr server
virsh domifaddr node-0
virsh domifaddr node-1
```

```sh
ssh cowboy@jumpbox_ip
```

Once all four machines are provisioned, verify the OS requirements by viewing the `/etc/os-release` file:

```bash
cat /etc/os-release
```

You should see something similar to the following output:

```text
NAME=Gentoo
ID=gentoo
PRETTY_NAME="Gentoo Linux"
ANSI_COLOR="1;32"
HOME_URL="https://www.gentoo.org/"
```

Next: [setting-up-the-jumpbox](02-jumpbox.md)
