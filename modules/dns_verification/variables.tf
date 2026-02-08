variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "verification_records" {
  description = "Map of domain verification TXT records"
  type = map(object({
    name    = string
    value   = string
    ttl     = optional(number, 3600)
    comment = optional(string, "Domain verification record")
  }))
}
