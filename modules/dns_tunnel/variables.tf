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
    # Protocol: http, https, tcp, ssh
    protocol = optional(string, "http")
    # Local port to tunnel to
    local_port = number
    # Optional: hostname for HTTP hostname header
    hostname = optional(string, "")
  }))
  default = {}
}
