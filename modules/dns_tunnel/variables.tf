variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

variable "domain" {
  type        = string
  description = "Base domain (e.g. briananderson.xyz)"
  default     = "briananderson.xyz"
}

variable "tunnel_name" {
  type        = string
  description = "Name for the shared Cloudflare Tunnel"
}

variable "services" {
  type = map(object({
    hostname    = string
    service_url = string
    access = optional(object({
      enabled            = optional(bool, true)
      service_token_name = optional(string, "")
      allowed_emails     = optional(list(string), [])
      session_duration   = optional(string, "24h")
    }), { enabled = true })
  }))
  description = "Services to expose via the shared tunnel"
  default     = {}
}
