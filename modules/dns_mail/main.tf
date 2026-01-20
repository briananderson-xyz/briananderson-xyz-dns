resource "cloudflare_dns_record" "mx" {
  for_each = { for idx, mx in var.mail_records.mx_servers : idx => mx }

  zone_id   = var.zone_id
  name      = "@"
  type      = "MX"
  value     = each.value.value
  priority  = each.value.priority
  proxied   = false
  ttl       = 3600
  comment   = "MX record for mail delivery"
}

resource "cloudflare_dns_record" "spf" {
  for_each = var.mail_records.spf != null ? { spf = var.mail_records.spf } : {}

  zone_id = var.zone_id
  name    = each.value.name
  type    = "TXT"
  value   = each.value.value
  proxied = false
  ttl     = 3600
  comment  = "SPF record to prevent spam"
}

resource "cloudflare_dns_record" "dkim" {
  for_each = var.mail_records.dkim != null ? { dkim = var.mail_records.dkim } : {}

  zone_id = var.zone_id
  name    = each.value.name
  type    = "TXT"
  value   = each.value.value
  proxied = false
  ttl     = 3600
  comment  = "DKIM record for email authentication"
}

resource "cloudflare_dns_record" "dmarc" {
  for_each = var.mail_records.dmarc != null ? { dmarc = var.mail_records.dmarc } : {}

  zone_id = var.zone_id
  name    = each.value.name
  type    = "TXT"
  value   = each.value.value
  proxied = false
  ttl     = 3600
  comment  = "DMARC record for email policy"
}
