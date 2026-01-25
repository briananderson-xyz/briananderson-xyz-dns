web_records = {
  "root" = {
    name    = "@"
    type    = "CNAME"
    value   = "c.storage.googleapis.com"
    proxied = true
    ttl     = 1
    comment = "Dev domain pointing to Google Storage"
  },
  "www" = {
    name    = "www"
    type    = "CNAME"
    value   = "c.storage.googleapis.com"
    proxied = true
    ttl     = 1
    comment = "Dev WWW subdomain pointing to Google Storage"
  }
}

web_default_proxied = true
web_default_ttl     = 1

mail_records = {
  mx_servers = []
}

homelab_public_ip = "1.1.1.1"
homelab_services  = {}

verification_records = {}
