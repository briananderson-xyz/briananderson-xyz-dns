terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_record" "verification" {
  for_each = var.verification_records

  zone_id = var.zone_id
  name    = each.value.name
  type    = "TXT"
  value   = each.value.value
  proxied = false
  ttl     = each.value.ttl
  comment  = try(each.value.comment, "Domain verification record")
}
