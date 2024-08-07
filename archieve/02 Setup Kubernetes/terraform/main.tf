terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

provider "proxmox" {
  pm_log_enable = true
  pm_debug      = true
  # Follow Proxmox Setup https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#argument-reference
  pm_api_url          = "[FIXME_HOST_NAME]:8006/api2/json"
  pm_api_token_id     = "[FIXME_API]"
  pm_api_token_secret = "[FIXME_TOKEN]"
}