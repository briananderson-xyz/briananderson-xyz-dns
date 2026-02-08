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

variable "api_worker_config" {
  description = "API Worker configuration for proxying to Cloud Run functions"
  type = object({
    enabled                 = optional(bool, false)
    chat_function_url       = optional(string, "")
    fit_finder_function_url = optional(string, "")
  })
  default = {
    enabled = false
  }
}
