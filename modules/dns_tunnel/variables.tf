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

variable "tunnel_services" {
  description = "Services to expose via Cloudflare Tunnel with Zero Trust Access"
  type = map(object({
    tunnel_name = string
    hostname    = string # subdomain (e.g. 'affine-mcp' → affine-mcp.briananderson.xyz)
    service_url = string # local service URL (e.g. 'http://localhost:3011')
    access = optional(object({
      enabled            = optional(bool, true)
      service_token_name = optional(string, "") # creates a service token for machine auth
      allowed_emails     = optional(list(string), [])
      session_duration   = optional(string, "24h")
    }), { enabled = true })
  }))
  default = {}
}
