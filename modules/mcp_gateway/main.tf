terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

resource "cloudflare_workers_script" "mcp_gateway" {
  account_id  = var.account_id
  script_name = "mcp-gateway"
  content     = file("${path.module}/worker.js")
  main_module = "worker.js"

  compatibility_date = "2024-01-01"

  bindings = [
    {
      type = "secret_text"
      name = "BEARER_TOKEN"
      text = var.bearer_token
    },
    {
      type = "secret_text"
      name = "ROUTES"
      text = jsonencode(var.routes)
    },
  ]
}

resource "cloudflare_workers_route" "mcp_gateway" {
  zone_id = var.zone_id
  pattern = "${var.hostname}.${var.domain}/*"
  script  = cloudflare_workers_script.mcp_gateway.script_name

  depends_on = [cloudflare_workers_script.mcp_gateway]
}

resource "cloudflare_dns_record" "mcp_gateway" {
  zone_id = var.zone_id
  name    = var.hostname
  type    = "AAAA"
  content = "100::"
  proxied = true
  ttl     = 1
  comment = "MCP Gateway Worker"
}
