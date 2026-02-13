terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_tunnel" "tunnel" {
  for_each = var.tunnel_services

  name       = each.value.tunnel_name
  account_id = var.account_id
  secret     = each.value.tunnel_secret != "" ? each.value.tunnel_secret : uuid()
}

resource "cloudflare_record" "tunnel_cname" {
  for_each = { for k, v in var.tunnel_services : k => v if v.hostname != "" }

  zone_id = var.zone_id
  name    = each.value.hostname
  type    = "CNAME"
  value   = "${cloudflare_tunnel.tunnel[each.key].id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

resource "cloudflare_tunnel_config" "config" {
  for_each = var.tunnel_services

  account_id = var.account_id
  tunnel_id  = cloudflare_tunnel.tunnel[each.key].id
  config {
    ingress_rule {
      hostname = var.tunnel_services[each.key].hostname
      service  = "${var.tunnel_services[each.key].protocol}://localhost:${var.tunnel_services[each.key].local_port}"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}
