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
resource "cloudflare_dns_record" "api" {
  zone_id = var.zone_id
  name    = var.dns_name
  type    = "A"
  content = "199.36.158.100"
  proxied = true
  ttl     = 1
  comment = "API subdomain — Firebase Hosting origin, routed via Cloudflare Worker"
}

# KV namespace backing per-IP rate limiting and the AI kill switch.
# Each worker instance (prod / dev) gets its own so their state is isolated.
resource "cloudflare_workers_kv_namespace" "api_state" {
  account_id = var.account_id
  title      = "${var.script_name}-state"
}

# Worker script that proxies /chat, /fit-finder, and /mcp to Cloud Run,
# with edge per-IP rate limiting and an AI kill switch (see worker.js).
resource "cloudflare_workers_script" "api_proxy" {
  account_id  = var.account_id
  script_name = var.script_name
  content     = file("${path.module}/worker.js")
  main_module = "worker.js"

  bindings = [
    {
      name = "CHAT_URL"
      type = "plain_text"
      text = var.chat_function_url
    },
    {
      name = "FIT_FINDER_URL"
      type = "plain_text"
      text = var.fit_finder_function_url
    },
    {
      name = "RATE_LIMIT"
      type = "plain_text"
      text = tostring(var.rate_limit)
    },
    {
      name = "RATE_WINDOW_SECONDS"
      type = "plain_text"
      text = tostring(var.rate_window_seconds)
    },
    {
      name         = "API_STATE"
      type         = "kv_namespace"
      namespace_id = cloudflare_workers_kv_namespace.api_state.id
    }
  ]
}

# Route api.briananderson.xyz/* to the worker
resource "cloudflare_workers_route" "api" {
  zone_id = var.zone_id
  pattern = var.route_pattern
  script  = cloudflare_workers_script.api_proxy.script_name
}
