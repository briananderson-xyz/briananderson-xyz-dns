terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

resource "cloudflare_dns_record" "web" {
  for_each = var.web_records

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  proxied = try(each.value.proxied, var.default_proxied)
  ttl     = try(each.value.ttl, var.default_ttl)
  comment = try(each.value.comment, "Web record managed by Terraform")
}
