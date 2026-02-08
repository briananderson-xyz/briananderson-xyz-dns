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
