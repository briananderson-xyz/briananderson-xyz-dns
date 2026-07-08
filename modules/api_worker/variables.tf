variable "account_id" {
  type        = string
  description = "Cloudflare account ID"
}

variable "zone_id" {
  type        = string
  description = "Cloudflare zone ID"
}

variable "script_name" {
  type        = string
  default     = "api-proxy"
  description = "Name for the Cloudflare Worker script"
}

variable "chat_function_url" {
  type        = string
  description = "Cloud Run URL for the chat function"
}

variable "fit_finder_function_url" {
  type        = string
  description = "Cloud Run URL for the fit-finder function"
}

variable "origin_verify_token" {
  type        = string
  description = "Shared secret sent to Cloud Run as X-Origin-Verify"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.origin_verify_token)) >= 32
    error_message = "origin_verify_token must be at least 32 characters."
  }
}

variable "route_pattern" {
  type        = string
  default     = "api.briananderson.xyz/*"
  description = "URL pattern for the Worker route"
}

variable "dns_name" {
  type        = string
  default     = "api.briananderson.xyz"
  description = "DNS record name for the API subdomain"
}

variable "rate_limit" {
  type        = number
  default     = 15
  description = "Max requests per IP per window on the proxied AI endpoints"
}

variable "rate_window_seconds" {
  type        = number
  default     = 600
  description = "Rate-limit window length in seconds (default 10 minutes)"
}
