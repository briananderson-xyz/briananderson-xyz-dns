module "dns_web" {
  source = "./modules/dns_web"

  zone_id     = var.cloudflare_zone_id
  web_records = local.web_records
}

module "dns_mail" {
  source = "./modules/dns_mail"

  zone_id      = var.cloudflare_zone_id
  mail_records = local.mail_records
}

module "dns_homelab" {
  source = "./modules/dns_homelab"

  zone_id  = var.cloudflare_zone_id
  services = {}
}

module "dns_verification" {
  source = "./modules/dns_verification"

  zone_id              = var.cloudflare_zone_id
  verification_records = local.verification_records
}

module "api_worker" {
  source = "./modules/api_worker"

  account_id              = var.cloudflare_account_id
  zone_id                 = var.cloudflare_zone_id
  chat_function_url       = local.api_worker.chat_function_url
  fit_finder_function_url = local.api_worker.fit_finder_function_url
}

module "zone_settings" {
  source = "./modules/zone_settings"

  zone_id          = var.cloudflare_zone_id
  domain           = "briananderson.xyz"
  always_use_https = true
  www_redirect     = true
}
