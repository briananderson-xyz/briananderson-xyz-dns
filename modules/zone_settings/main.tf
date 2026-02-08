terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

resource "cloudflare_zone_setting" "always_use_https" {
  count = var.always_use_https ? 1 : 0

  zone_id    = var.zone_id
  setting_id = "always_use_https"
  value      = "on"
}

resource "cloudflare_ruleset" "www_redirect" {
  count = var.www_redirect ? 1 : 0

  zone_id     = var.zone_id
  name        = "www-to-root-redirect"
  description = "Redirect www to root domain"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [{
    ref         = "redirect_www_to_root"
    description = "301 redirect www.${var.domain} to ${var.domain}"
    expression  = "(starts_with(http.host, \"www.\"))"
    action      = "redirect"
    enabled     = true
    action_parameters = {
      from_value = {
        status_code = 301
        target_url = {
          expression = "concat(\"https://${var.domain}\", http.request.uri.path)"
        }
        preserve_query_string = true
      }
    }
  }]
}
