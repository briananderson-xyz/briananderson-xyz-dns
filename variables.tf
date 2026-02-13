variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token with DNS:Edit and Zone:Read scopes"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID for briananderson.xyz"
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
  default     = ""
}

variable "web_records" {
  description = "Web DNS records configuration"
  type = map(object({
    name    = string
    type    = string
    value   = string
    proxied = optional(bool, true)
    ttl     = optional(number, 3600)
    comment = optional(string, "")
  }))
  default = {}
}

variable "web_default_proxied" {
  type        = bool
  default     = true
  description = "Default proxy status for web records"
}

variable "web_default_ttl" {
  type        = number
  default     = 3600
  description = "Default TTL for web records"
}

variable "mail_records" {
  description = "Mail DNS records configuration"
  type = object({
    mx_servers = list(object({
      priority = number
      value    = string
    }))
    spf = optional(object({
      name  = string
      value = string
    }), null)
    dkim = optional(object({
      name  = string
      value = string
    }), null)
    dmarc = optional(object({
      name  = string
      value = string
    }), null)
  })
  default = {
    mx_servers = []
  }
}

variable "homelab_public_ip" {
  type        = string
  description = "Public IP address of homelab"
  default     = ""
}

variable "homelab_services" {
  description = "Homelab service DNS records"
  type = map(object({
    name    = optional(string, "")
    proxied = optional(bool, true)
    ttl     = optional(number, 3600)
    comment = optional(string, "Homelab service managed by Terraform")
  }))
  default = {}
}

variable "verification_records" {
  description = "Domain verification TXT records"
  type = map(object({
    name    = string
    value   = string
    ttl     = optional(number, 3600)
    comment = optional(string, "Domain verification record")
  }))
  default = {}
}

variable "tunnel_services" {
  description = "Tunnel service configuration"
  type = map(object({
    tunnel_name   = string
    tunnel_secret = optional(string, "")
    protocol      = optional(string, "http")
    local_port    = number
    hostname      = optional(string, "")
  }))
  default = {}
}
