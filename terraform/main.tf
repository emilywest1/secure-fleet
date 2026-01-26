provider "proxmox" {
  pm_api_url = var.PROX_URL
  
  pm_api_token_id     = var.PROX_API_ID
  pm_api_token_secret = var.PROX_API_KEY
  
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "ubuntu-server-vm" {
  name    = "myvm"
  target_node = var.PROX_NODE
  clone   = "ubuntu-template"
}
