web_records = {
  "dev" = {
    name    = "dev"
    type    = "CNAME"
    value   = "c.storage.googleapis.com"
    proxied = true
    ttl     = 300
    comment = "Development environment"
  },
  "admin" = {
    name    = "admin"
    type    = "A"
    value   = "192.0.2.1"
    proxied = true
    ttl     = 1
    comment = "Admin interface"
  },
  "fairview" = {
    name    = "fairview"
    type    = "A"
    value   = "192.0.2.1"
    proxied = true
    ttl     = 1
  },
  "auth" = {
    name    = "auth"
    type    = "CNAME"
    value   = "ghs.googlehosted.com"
    proxied = true
    ttl     = 1
  },
  "root" = {
    name    = "@"
    type    = "CNAME"
    value   = "c.storage.googleapis.com"
    proxied = true
    ttl     = 1
    comment = "Main domain pointing to Google Storage"
  },
  "www" = {
    name    = "www"
    type    = "CNAME"
    value   = "c.storage.googleapis.com"
    proxied = true
    ttl     = 1
    comment = "WWW subdomain pointing to Google Storage"
  },
  "domainconnect" = {
    name    = "_domainconnect"
    type    = "CNAME"
    value   = "_domainconnect.domains.squarespace.com"
    proxied = true
    ttl     = 1
  },
  "home" = {
    name    = "home"
    type    = "CNAME"
    value   = "your-ddns-service.com"
    proxied = false
    ttl     = 1
    comment = "Dynamic DNS for homelab (masked for security)"
  }
}

web_default_proxied = true
web_default_ttl     = 1

mail_records = {
  mx_servers = [
    { priority = 1, value = "aspmx.l.google.com" },
    { priority = 5, value = "alt1.aspmx.l.google.com" },
    { priority = 5, value = "alt2.aspmx.l.google.com" },
    { priority = 10, value = "alt3.aspmx.l.google.com" },
    { priority = 10, value = "alt4.aspmx.l.google.com" }
  ],
  spf = {
    name  = "@"
    value = "v=spf1 include:_spf.google.com ~all"
  }
}

homelab_public_ip = ""
homelab_services  = {}

verification_records = {}
