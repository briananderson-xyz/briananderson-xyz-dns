terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

resource "cloudflare_dns_record" "homelab" {
  for_each = var.services

  zone_id = var.zone_id
  name    = each.value.name != "" ? each.value.name : each.key
  type    = "A"
  content = var.public_ip
  proxied = each.value.proxied
  ttl     = each.value.ttl
  comment = each.value.comment
}
