terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  for_each = var.tunnel_services

  account_id = var.account_id
  name       = each.value.tunnel_name
}

resource "cloudflare_dns_record" "tunnel_cname" {
  for_each = { for k, v in var.tunnel_services : k => v if v.hostname != "" }

  zone_id = var.zone_id
  name    = each.value.hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel[each.key].id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}
