# DNS record definitions
# These are public DNS records — all values are queryable via dig/nslookup.

locals {
  web_records = {
    "root" = {
      name    = "@"
      type    = "CNAME"
      value   = "c.storage.googleapis.com"
      proxied = true
      ttl     = 1
      comment = "Main domain pointing to Google Storage"
    }
    "www" = {
      name    = "www"
      type    = "CNAME"
      value   = "c.storage.googleapis.com"
      proxied = true
      ttl     = 1
      comment = "WWW subdomain pointing to Google Storage"
    }
    "dev" = {
      name    = "dev"
      type    = "CNAME"
      value   = "c.storage.googleapis.com"
      proxied = true
      ttl     = 1
      comment = "Development environment"
    }
    "admin" = {
      name    = "admin"
      type    = "A"
      value   = "192.0.2.1"
      proxied = true
      ttl     = 1
      comment = "Admin interface"
    }
    "fairview" = {
      name    = "fairview"
      type    = "A"
      value   = "192.0.2.1"
      proxied = true
      ttl     = 1
    }
    "auth" = {
      name    = "auth"
      type    = "CNAME"
      value   = "ghs.googlehosted.com"
      proxied = true
      ttl     = 1
    }
    "domainconnect" = {
      name    = "_domainconnect"
      type    = "CNAME"
      value   = "_domainconnect.domains.squarespace.com"
      proxied = true
      ttl     = 1
    }
    "home" = {
      name    = "home"
      type    = "CNAME"
      value   = "your-ddns-service.com"
      proxied = false
      ttl     = 1
      comment = "Dynamic DNS for homelab"
    }
  }

  mail_records = {
    mx_servers = [
      { priority = 1, value = "aspmx.l.google.com" },
      { priority = 5, value = "alt1.aspmx.l.google.com" },
      { priority = 5, value = "alt2.aspmx.l.google.com" },
      { priority = 10, value = "alt3.aspmx.l.google.com" },
      { priority = 10, value = "alt4.aspmx.l.google.com" },
    ]
    spf = {
      name  = "@"
      value = "v=spf1 include:_spf.google.com ~all"
    }
    dkim = {
      name  = "google._domainkey"
      value = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoKkd7JKXz50wzbCJMzrKTTB5IN7BbaUd9ydmQ+MeBBRAxLOX1KTZMP41Jc8zzYTztK7F/GTx7J94cmlhBbaYVrAlhk1df8RxvW0A2amnuVFAS0xgmv6qCYAfCG7JHJAaRomBJRmkxwKBL5LbY1ffODrMMz9RMZsD2VI9TD+Lm1dK89mcthPu8LDlf3x3cFCOMw+IRvrwI7FX1cN3qW5qVoEN/h+SH5k82hzfTFyjsraPgIvOtM2Wr9yUuYRor3I/pqkMoThytLP1ABJgbBix3WedabMHF/7munlissz6b6zJcmNajuNIIFqyPidpvwVzcZMmfs+eghXjrq9yVbqTcQIDAQAB"
    }
    dmarc = {
      name  = "_dmarc"
      value = "v=DMARC1; p=none; rua=mailto:brian.anderson1222@gmail.com"
    }
  }

  verification_records = {
    "api-hosting" = {
      name    = "api"
      value   = "hosting-site=briananderson-xyz-ai"
      ttl     = 1
      comment = "Firebase hosting verification for API"
    }
    "api-acme" = {
      name    = "_acme-challenge.api"
      value   = "xd1JQooBpi8m23eTWL_yax6rWZ6MrkQ7k6HfM6P4jgk"
      ttl     = 1
      comment = "ACME challenge for API SSL"
    }
    "dmarc-cloudflare" = {
      name    = "_dmarc"
      value   = "v=DMARC1; p=none; rua=mailto:ce766ebb1e01429b84c6c35786232ed0@dmarc-reports.cloudflare.net"
      ttl     = 1
      comment = "Cloudflare DMARC reporting"
    }
  }
}
