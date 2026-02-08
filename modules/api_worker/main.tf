terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# DNS record for api.briananderson.xyz
# Points to a dummy IP — Cloudflare Worker intercepts before reaching origin
resource "cloudflare_record" "api" {
  zone_id = var.zone_id
  name    = var.dns_name
  type    = "A"
  content = "192.0.2.1"
  proxied = true
  ttl     = 1
  comment = "API subdomain — routed to Cloudflare Worker"
}

# Worker script that proxies /chat and /fit-finder to Cloud Run
resource "cloudflare_workers_script" "api_proxy" {
  account_id = var.account_id
  script_name = var.script_name
  content    = file("${path.module}/worker.js")
  main_module = "worker.js"

  bindings {
    name = "CHAT_URL"
    type = "plain_text"
    text = var.chat_function_url
  }

  bindings {
    name = "FIT_FINDER_URL"
    type = "plain_text"
    text = var.fit_finder_function_url
  }
}

# Route api.briananderson.xyz/* to the worker
resource "cloudflare_workers_route" "api" {
  zone_id     = var.zone_id
  pattern     = var.route_pattern
  script_name = cloudflare_workers_script.api_proxy.script_name
}
