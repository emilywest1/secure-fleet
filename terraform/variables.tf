variable "PROX_URL" {
  description = "URL to Proxmox server"
  type        = string
}

variable "PROX_USERNAME" {
  description = "Username for Proxmox server"
  type        = string
}

variable "PROX_NODE" {
  description = "Target node name (host of VM template)"
  type        = string
}

variable "PROX_API_KEY" {
  description = "API Key for Proxmox server"
  type        = string
  sensitive=true
}