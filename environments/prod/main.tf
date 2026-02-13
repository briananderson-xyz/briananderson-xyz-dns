module "dns_web" {
  source = "../../modules/dns_web"

  zone_id         = var.cloudflare_zone_id
  web_records     = var.web_records
  default_proxied = var.web_default_proxied
  default_ttl     = var.web_default_ttl
}

module "dns_mail" {
  source = "../../modules/dns_mail"

  zone_id         = var.cloudflare_zone_id
  mail_records    = var.mail_records
  dkim_enabled    = var.dkim_public_key != ""
  dkim_public_key = var.dkim_public_key
}

module "dns_homelab" {
  source = "../../modules/dns_homelab"

  zone_id   = var.cloudflare_zone_id
  public_ip = "1.1.1.1"
  services  = var.homelab_services
}

module "dns_verification" {
  count  = var.google_site_verification != "" ? 1 : 0
  source = "../../modules/dns_verification"

  zone_id = var.cloudflare_zone_id
  verification_records = {
    google-site-verification = {
      name    = "@"
      value   = "google-site-verification=${var.google_site_verification}"
      ttl     = 1
      comment = "Domain verification token"
    }
  }
}

module "dns_tunnel" {
  count  = length(var.tunnel_services) > 0 ? 1 : 0
  source = "../../modules/dns_tunnel"

  zone_id         = var.cloudflare_zone_id
  account_id      = var.cloudflare_account_id
  tunnel_services = var.tunnel_services
}
