terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_record" "mx" {
  for_each = { for idx, mx in var.mail_records.mx_servers : idx => mx }

  zone_id  = var.zone_id
  name     = "@"
  type     = "MX"
  value    = each.value.value
  priority = each.value.priority
  proxied  = false
  ttl      = 3600
  comment  = "MX record for mail delivery"
}

resource "cloudflare_record" "spf" {
  for_each = var.mail_records.spf != null ? { spf = var.mail_records.spf } : {}

  zone_id = var.zone_id
  name    = each.value.name
  type    = "TXT"
  value   = each.value.value
  proxied = false
  ttl     = 3600
  comment = "SPF record to prevent spam"
}

resource "cloudflare_record" "dkim" {
  count   = var.dkim_enabled ? 1 : 0
  zone_id = var.zone_id
  name    = "google._domainkey"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=${var.dkim_public_key}"
  proxied = false
  ttl     = 3600
  comment = "DKIM record for email authentication"
}

resource "cloudflare_record" "dmarc" {
  for_each = var.mail_records.dmarc != null ? { dmarc = var.mail_records.dmarc } : {}

  zone_id = var.zone_id
  name    = each.value.name
  type    = "TXT"
  value   = each.value.value
  proxied = false
  ttl     = 3600
  comment = "DMARC record for email policy"
}
