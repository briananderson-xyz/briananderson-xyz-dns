terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# =============================================================================
# Cloudflare Tunnels
# =============================================================================

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  for_each = var.tunnel_services

  account_id    = var.account_id
  name          = each.value.tunnel_name
  config_src    = "cloudflare"
  tunnel_secret = base64encode(random_bytes.tunnel_secret[each.key].hex)
}

resource "random_bytes" "tunnel_secret" {
  for_each = var.tunnel_services
  length   = 32
}

# =============================================================================
# Tunnel Ingress Configuration
# =============================================================================

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "config" {
  for_each = var.tunnel_services

  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel[each.key].id

  config = {
    ingress = [
      {
        hostname = "${each.value.hostname}.${var.domain}"
        service  = each.value.service_url
      },
      {
        # Catch-all rule (required by Cloudflare)
        service = "http_status:404"
      },
    ]
  }
}

# =============================================================================
# DNS CNAME Records → Tunnel
# =============================================================================

resource "cloudflare_dns_record" "tunnel_cname" {
  for_each = { for k, v in var.tunnel_services : k => v if v.hostname != "" }

  zone_id = var.zone_id
  name    = each.value.hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel[each.key].id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

# =============================================================================
# Zero Trust Access — Service Tokens (for machine-to-machine auth)
# =============================================================================

locals {
  services_with_token = {
    for k, v in var.tunnel_services : k => v
    if v.access.enabled && v.access.service_token_name != ""
  }

  services_with_access = {
    for k, v in var.tunnel_services : k => v
    if v.access.enabled
  }
}

resource "cloudflare_zero_trust_access_service_token" "token" {
  for_each = local.services_with_token

  account_id = var.account_id
  name       = each.value.access.service_token_name
  duration   = "8760h" # 1 year
}

# =============================================================================
# Zero Trust Access — Application (protects the hostname)
# =============================================================================

resource "cloudflare_zero_trust_access_application" "app" {
  for_each = local.services_with_access

  account_id = var.account_id
  name       = each.value.tunnel_name
  domain     = "${each.value.hostname}.${var.domain}"
  type       = "self_hosted"

  session_duration          = each.value.access.session_duration
  app_launcher_visible      = false
  skip_interstitial         = true
  service_auth_401_redirect = true

  # Link policies to this application
  policies = concat(
    # Service token policy (if applicable)
    contains(keys(local.services_with_token), each.key) ? [{
      id         = cloudflare_zero_trust_access_policy.service_token[each.key].id
      precedence = 1
    }] : [],
    # Email policy (if applicable)
    contains(keys(local.services_with_emails), each.key) ? [{
      id         = cloudflare_zero_trust_access_policy.email[each.key].id
      precedence = 2
    }] : [],
  )
}

# =============================================================================
# Zero Trust Access — Policy: Allow via Service Token
# =============================================================================

resource "cloudflare_zero_trust_access_policy" "service_token" {
  for_each = local.services_with_token

  account_id = var.account_id
  name       = "Allow ${each.value.access.service_token_name}"
  decision   = "non_identity"

  include = [{
    any_valid_service_token = {}
  }]

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# Zero Trust Access — Policy: Allow by Email (browser login for humans)
# =============================================================================

locals {
  services_with_emails = {
    for k, v in var.tunnel_services : k => v
    if v.access.enabled && length(v.access.allowed_emails) > 0
  }
}

resource "cloudflare_zero_trust_access_policy" "email" {
  for_each = local.services_with_emails

  account_id = var.account_id
  name       = "Allow emails for ${each.value.tunnel_name}"
  decision   = "allow"

  include = [
    for email in each.value.access.allowed_emails : {
      email = {
        email = email
      }
    }
  ]

  lifecycle {
    create_before_destroy = true
  }
}
