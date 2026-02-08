module "dns_web" {
  source = "./modules/dns_web"

  zone_id         = var.cloudflare_zone_id
  web_records     = var.web_records
  default_proxied = var.web_default_proxied
  default_ttl     = var.web_default_ttl
}

module "dns_mail" {
  source = "./modules/dns_mail"

  zone_id      = var.cloudflare_zone_id
  mail_records = var.mail_records
}

module "dns_homelab" {
  source = "./modules/dns_homelab"

  zone_id   = var.cloudflare_zone_id
  public_ip = var.homelab_public_ip
  services  = var.homelab_services
}

module "dns_verification" {
  source = "./modules/dns_verification"

  zone_id              = var.cloudflare_zone_id
  verification_records = var.verification_records
}

module "api_worker" {
  source = "./modules/api_worker"
  count  = var.api_worker_config.enabled ? 1 : 0

  account_id             = var.cloudflare_account_id
  zone_id                = var.cloudflare_zone_id
  chat_function_url      = var.api_worker_config.chat_function_url
  fit_finder_function_url = var.api_worker_config.fit_finder_function_url
}
