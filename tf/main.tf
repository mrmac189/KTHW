terraform {
  required_version = ">= 1.5.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.9.4"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "ssh_public_key" {
  description = "Public SSH key for the cowboy user"
  type        = string
}

variable "libvirt_pool" {
  description = "Existing libvirt storage pool"
  type        = string
  default     = "default"
}

variable "libvirt_network" {
  description = "Existing libvirt network"
  type        = string
  default     = "default"
}

variable "ovmf_code" {
  description = "Path to OVMF_CODE on the host"
  type        = string
  default     = "/usr/share/edk2/OvmfX64/OVMF_CODE.fd"
}

variable "ovmf_vars" {
  description = "Path to OVMF_VARS template on the host"
  type        = string
  default     = "/usr/share/edk2/OvmfX64/OVMF_VARS.fd"
}

variable "cowboy_password_hash" {
  type      = string
  sensitive = true
}

locals {
  gib = 1024 * 1024 * 1024

  gentoo_cloud_image = "https://distfiles.gentoo.org/releases/amd64/autobuilds/20260308T170100Z/di-amd64-cloudinit-20260308T170100Z.qcow2"

  machines = {
    jumpbox = {
      vcpu      = 1
      memory_mb = 2048
      disk_size = 20 * local.gib
    }
    server = {
      vcpu      = 1
      memory_mb = 2048
      disk_size = 20 * local.gib
    }
    node-0 = {
      vcpu      = 1
      memory_mb = 2048
      disk_size = 20 * local.gib
    }
    node-1 = {
      vcpu      = 1
      memory_mb = 2048
      disk_size = 20 * local.gib
    }
  }
}

resource "libvirt_volume" "gentoo_base" {
  name = "di-amd64-cloudinit-20260308T170100Z.qcow2"
  pool = var.libvirt_pool

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = local.gentoo_cloud_image
    }
  }
}

resource "libvirt_volume" "root_disk" {
  for_each = local.machines

  name     = "${each.key}.qcow2"
  pool     = var.libvirt_pool
  capacity = each.value.disk_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.gentoo_base.path

    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_cloudinit_disk" "seed" {
  for_each = local.machines

  name = "${each.key}-seed"

  user_data = <<-EOF
    #cloud-config
    hostname: ${each.key}
    fqdn: ${each.key}.kthw.local
    manage_etc_hosts: true
    ssh_pwauth: false

    users:
      - name: cowboy
        gecos: Cowboy User
        groups: [wheel]
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        lock_passwd: false
        ssh_authorized_keys:
          - ${var.ssh_public_key}
        hashed_passwd: ${var.cowboy_password_hash}

    runcmd:
      - [ sh, -lc, "systemctl enable --now sshd" ]
  EOF

  meta_data = <<-EOF
    instance-id: ${each.key}
    local-hostname: ${each.key}
  EOF
}

resource "libvirt_volume" "seed_iso" {
  for_each = local.machines

  name = "${each.key}-seed.iso"
  pool = var.libvirt_pool

  create = {
    content = {
      url = libvirt_cloudinit_disk.seed[each.key].path
    }
  }
}

resource "libvirt_domain" "vm" {
  for_each = local.machines

  name        = each.key
  memory      = each.value.memory_mb
  memory_unit = "MiB"
  vcpu        = each.value.vcpu
  type        = "kvm"
  autostart   = true
  running     = true

  features = {
  	acpi = true
	}

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"

    firmware        = "efi"
    loader          = var.ovmf_code

    nv_ram = {
      nv_ram   = "/var/lib/libvirt/qemu/nvram/${each.key}.fd"
      template = var.ovmf_vars
    }

    boot_devices = [
        {
          dev = "hd"
        }
      ]
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.root_disk[each.key].pool
            volume = libvirt_volume.root_disk[each.key].name
          }
        }

        target = {
          dev = "vda"
          bus = "virtio"
        }

        driver = {
          type = "qcow2"
        }
      },
      {
        device = "cdrom"

        source = {
          volume = {
            pool   = libvirt_volume.seed_iso[each.key].pool
            volume = libvirt_volume.seed_iso[each.key].name
          }
        }

        target = {
          dev = "sda"
          bus = "sata"
        }
      }
    ]

    interfaces = [
      {
        model = {
          type = "virtio"
        }

        source = {
          network = {
            network = var.libvirt_network
          }
        }

	wait_for_ip = {
  		timeout = 300
  		source  = "lease"
	}
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_type = "serial"
        target_port = "0"
      }
    ]

    rngs = [
      {
        model = "virtio"
        backend = {
          random = "/dev/urandom"
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "127.0.0.1"
        }
      }
    ]
    video = {
      type = "virtio"
    }
  }
}

data "libvirt_domain_interface_addresses" "vm" {
  for_each = local.machines

  domain = libvirt_domain.vm[each.key].name
  source = "lease"
}

output "vm_ips" {
  value = {
    for name, iface in data.libvirt_domain_interface_addresses.vm :
    name => try(iface.interfaces[0].addrs[0].addr, "no-ip-yet")
  }
}
