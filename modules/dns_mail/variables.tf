variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
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
}

variable "dkim_enabled" {
  type        = bool
  default     = false
  description = "Whether to create DKIM record"
}

variable "dkim_public_key" {
  type        = string
  default     = ""
  description = "Gmail DKIM public key (after p=)"
  sensitive   = true
}
