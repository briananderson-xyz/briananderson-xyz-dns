variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID for briananderson.xyz"
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

variable "mcp_gateway_bearer_token" {
  type        = string
  description = "Bearer token for MCP Gateway authentication"
  sensitive   = true
}

variable "mcp_gateway_routes" {
  type = map(object({
    url     = string
    headers = optional(map(string), {})
  }))
  description = "MCP Gateway routes: path prefix → backend"
  default     = {}
}
