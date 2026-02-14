variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "account_id" {
  type        = string
  description = "Cloudflare Account ID"
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
