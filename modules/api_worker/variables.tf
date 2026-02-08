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
