variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "domain" {
  type        = string
  description = "Root domain name (e.g., briananderson.xyz)"
}

variable "always_use_https" {
  type        = bool
  default     = true
  description = "Enable Always Use HTTPS zone setting"
}

variable "www_redirect" {
  type        = bool
  default     = true
  description = "Enable www to root domain 301 redirect"
}
