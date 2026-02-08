variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "public_ip" {
  type        = string
  description = "Public IP address of homelab"
  default     = ""
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
