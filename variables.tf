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

variable "origin_verify_token_prod" {
  type        = string
  description = "Shared secret injected by the prod API Worker and required by prod Cloud Run"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.origin_verify_token_prod)) >= 32
    error_message = "origin_verify_token_prod must be at least 32 characters."
  }
}

variable "origin_verify_token_dev" {
  type        = string
  description = "Shared secret injected by the dev API Worker and required by dev Cloud Run"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.origin_verify_token_dev)) >= 32
    error_message = "origin_verify_token_dev must be at least 32 characters."
  }
}

variable "mcp_gateway_routes" {
  type = map(object({
    url     = string
    headers = optional(map(string), {})
  }))
  description = "MCP Gateway routes: path prefix → backend"
  default     = {}
}
