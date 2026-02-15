variable "account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "hostname" {
  type        = string
  description = "Hostname for the MCP gateway (e.g. mcp)"
  default     = "mcp"
}

variable "domain" {
  type        = string
  description = "Base domain"
  default     = "briananderson.xyz"
}

variable "bearer_token" {
  type        = string
  description = "Bearer token for authenticating MCP clients"
  sensitive   = true
}

variable "routes" {
  type        = map(object({
    url     = string
    headers = optional(map(string), {})
  }))
  description = "Route map: prefix → backend URL + optional headers"
}
