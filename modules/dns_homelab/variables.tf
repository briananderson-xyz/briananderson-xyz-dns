variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "public_ip" {
  type        = string
  description = "Public IP address of homelab"
  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.public_ip))
    error_message = "Must be a valid IPv4 address."
  }
}

variable "services" {
  description = "Map of homelab service DNS records"
  type = map(object({
    name    = optional(string, "")
    proxied = optional(bool, true)
    ttl     = optional(number, 3600)
    comment = optional(string, "Homelab service managed by Terraform")
  }))
}
