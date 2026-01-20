resource "cloudflare_dns_record" "verification" {
  for_each = var.verification_records

  zone_id = var.zone_id
  name    = each.value.name
  type    = "TXT"
  value   = each.value.value
  proxied = false
  ttl     = each.value.ttl
  comment = try(each.value.comment, "Domain verification record")
}
