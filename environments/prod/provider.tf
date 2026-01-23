variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token with DNS:Edit and Zone:Read scopes"
  sensitive   = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

