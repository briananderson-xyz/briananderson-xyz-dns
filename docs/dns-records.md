# DNS Records Reference

Quick reference for all DNS records managed by this project. Record values are configured per-environment in `terraform.tfvars` (gitignored).

## Web Records (`dns_web` module)

| Subdomain | Type | Target | Proxied | Notes |
|-----------|------|--------|---------|-------|
| `@` | CNAME | c.storage.googleapis.com | Yes | Root domain |
| `www` | CNAME | c.storage.googleapis.com | Yes | Main website |
| `admin` | A | (in tfvars) | Yes | Admin panel |
| `fairview` | A | (in tfvars) | Yes | Fairview site |
| `auth` | CNAME | ghs.googlehosted.com | Yes | Google Workspace auth |
| `_domainconnect` | CNAME | Squarespace domain connect | Yes | Squarespace integration |
| `home` | CNAME | (in tfvars) | No | Homelab DDNS |

## Mail Records (`dns_mail` module)

| Name | Type | Value | Priority |
|------|------|-------|----------|
| `@` | MX | aspmx.l.google.com | 1 |
| `@` | MX | alt1.aspmx.l.google.com | 5 |
| `@` | MX | alt2.aspmx.l.google.com | 5 |
| `@` | MX | alt3.aspmx.l.google.com | 10 |
| `@` | MX | alt4.aspmx.l.google.com | 10 |
| `google._domainkey` | TXT | (DKIM key, in tfvars) | - |

## Verification Records (`dns_verification` module)

| Name | Type | Value |
|------|------|-------|
| `@` | TXT | (google-site-verification token, in tfvars) |

## NS Records (not managed by Terraform)

| Name | Value |
|------|-------|
| `@` | ns-cloud-b1.googledomains.com |
| `@` | ns-cloud-b2.googledomains.com |
| `@` | ns-cloud-b3.googledomains.com |
| `@` | ns-cloud-b4.googledomains.com |

## Notes

- **TTL = 1** means "auto" in Cloudflare
- **Proxied = Yes** means traffic routes through Cloudflare (DDoS protection, caching)
- **Proxied = No** means DNS-only (direct resolution, required for some services)
- Values marked "(in tfvars)" are configured per-environment and gitignored
