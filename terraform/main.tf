terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.95.0"
    }
  }
}

# Add this provider configuration block
provider "proxmox" {
   endpoint  = var.PROX_URL  # e.g., "https://192.168.1.100:8006/api2/json"
  api_token = var.PROX_API_KEY  # e.g., "root@pam!mytoken=12345678-1234-1234-1234-123456789abc"
  insecure  = true  # Set to true if using self-signed SSL certificate

}

resource "proxmox_virtual_environment_file" "cloudinit" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.PROX_NODE

  source_file {
    path = "cloudinit.tpl"
  }
}

resource "proxmox_virtual_environment_vm" "k8s_worker" {
  name      = "k8s-worker-01"
  node_name = var.PROX_NODE

  clone {
    vm_id = 124
    full  = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id      = "local"
    user_data_file_id = proxmox_virtual_environment_file.cloudinit.id

    ip_config {
      ipv4 {
        address = "192.168.1.50/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [file("~/.ssh/id_ed25519.pub")]
    }
  }

  depends_on = [
    proxmox_virtual_environment_file.cloudinit
  ]
}