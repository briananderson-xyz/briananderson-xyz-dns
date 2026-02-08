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