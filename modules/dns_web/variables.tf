variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "web_records" {
  description = "Map of web DNS records to create"
  type = map(object({
    name    = string
    type    = string
    value   = string
    proxied = optional(bool, false)
    ttl     = optional(number, 3600)
    comment = optional(string, "")
  }))
}

variable "default_proxied" {
  type        = bool
  default     = true
  description = "Default proxy status for web records"
}

variable "default_ttl" {
  type        = number
  default     = 3600
  description = "Default TTL for web records"
}
