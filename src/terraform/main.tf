terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.73"
    }
  }
}

provider "proxmox" {
  endpoint  = var.PROX_URL
  api_token = "${var.PROX_API_KEY}=${var.PROX_API_SECRET}"
  insecure  = true
}

locals {
  storage = "local-lvm"
  node    = var.PROX_NODE
  ssh_key = var.PROX_PUB_KEY
  bridge  = "vmbr0"
}

data "proxmox_virtual_environment_vms" "template" {
  filter {
    name   = "name"
    values = ["terr-ubuntu-template"]
  }
}

resource "proxmox_virtual_environment_vm" "control" {
  name      = "control"
  node_name = local.node

  clone {
    vm_id = data.proxmox_virtual_environment_vms.template.vms[0].vm_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "kvm64"
  }

  memory {
    dedicated = 4096
  }

  scsi_hardware = "virtio-scsi-pci"

  disk {
    datastore_id = local.storage
    interface    = "scsi0"
    size         = 32
    file_format  = "raw"
  }

  network_device {
    model  = "virtio"
    bridge = local.bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = "ubuntu"
      keys     = [local.ssh_key]
    }
  }

  lifecycle {
    ignore_changes = [network_device]
  }
}

resource "proxmox_virtual_environment_vm" "nodes" {
  for_each = {
    node1  = { memory = 4096 }
    node2  = { memory = 4096 }
    node3  = { memory = 4096 }
    nagios = { memory = 2048 }
  }

  depends_on = [proxmox_virtual_environment_vm.control]
  name       = each.key
  node_name  = local.node

  clone {
    vm_id = data.proxmox_virtual_environment_vms.template.vms[0].vm_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "kvm64"
  }

  memory {
    dedicated = each.value.memory
  }

  scsi_hardware = "virtio-scsi-pci"

  disk {
    datastore_id = local.storage
    interface    = "scsi0"
    size         = 32
    file_format  = "raw"
  }

  network_device {
    model  = "virtio"
    bridge = local.bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = "ubuntu"
      keys     = [local.ssh_key]
    }
  }

  lifecycle {
    ignore_changes = [network_device]
  }
}

output "vm_names" {
  value = {
    control = proxmox_virtual_environment_vm.control.vm_id
    node1   = proxmox_virtual_environment_vm.nodes["node1"].vm_id
    node2   = proxmox_virtual_environment_vm.nodes["node2"].vm_id
    node3   = proxmox_virtual_environment_vm.nodes["node3"].vm_id
    nagios  = proxmox_virtual_environment_vm.nodes["nagios"].vm_id
  }
}

output "nodes_ips" {
  value = {
    control = proxmox_virtual_environment_vm.control.ipv4_addresses[1][0]
    nodes = {
      for k, vm in proxmox_virtual_environment_vm.nodes : k => vm.ipv4_addresses[1][0]
    }

}
}
