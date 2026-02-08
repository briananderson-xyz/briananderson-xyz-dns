# DNS Records Reference

All DNS record definitions live in `records.tf` as Terraform locals.

## Web Records (`dns_web` module)

| Subdomain | Type | Target | Proxied | Notes |
|-----------|------|--------|---------|-------|
| `@` | CNAME | c.storage.googleapis.com | Yes | Root domain |
| `www` | CNAME | c.storage.googleapis.com | Yes | Main website |
| `dev` | CNAME | c.storage.googleapis.com | Yes | Dev environment |
| `admin` | A | 192.0.2.1 | Yes | Admin panel |
| `fairview` | A | 192.0.2.1 | Yes | Fairview site |
| `auth` | CNAME | ghs.googlehosted.com | Yes | Google Workspace auth |
| `_domainconnect` | CNAME | _domainconnect.domains.squarespace.com | Yes | Squarespace integration |
| `home` | CNAME | your-ddns-service.com | No | Homelab DDNS |

## Mail Records (`dns_mail` module)

| Name | Type | Value | Priority |
|------|------|-------|----------|
| `@` | MX | aspmx.l.google.com | 1 |
| `@` | MX | alt1.aspmx.l.google.com | 5 |
| `@` | MX | alt2.aspmx.l.google.com | 5 |
| `@` | MX | alt3.aspmx.l.google.com | 10 |
| `@` | MX | alt4.aspmx.l.google.com | 10 |
| `@` | TXT | v=spf1 include:_spf.google.com ~all | - |
| `google._domainkey` | TXT | DKIM public key | - |
| `_dmarc` | TXT | v=DMARC1; p=none; rua=mailto:... | - |

## Verification Records (`dns_verification` module)

| Name | Type | Purpose |
|------|------|---------|
| `api` | TXT | Firebase hosting verification |
| `_acme-challenge.api` | TXT | ACME challenge for API SSL |
| `_dmarc` | TXT | Cloudflare DMARC reporting |

## API Worker (`api_worker` module)

| Resource | Purpose |
|----------|---------|
| `api` DNS record | CNAME pointing to Cloudflare Workers |
| Workers script | Proxies requests to Cloud Run functions (chat, fit-finder) |
| Workers route | Routes `api.briananderson.xyz/*` to the script |

## Zone Settings (`zone_settings` module)

| Setting | Value | Purpose |
|---------|-------|---------|
| Always Use HTTPS | On | Redirect all HTTP to HTTPS |
| www redirect | 301 | Redirect www.briananderson.xyz to briananderson.xyz |

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
- **Proxied = No** means DNS-only (direct resolution)
