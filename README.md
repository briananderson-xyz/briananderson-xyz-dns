# briananderson-xyz-dns

Modular Terraform project to manage all DNS records for `briananderson.xyz` via Cloudflare.

## What This Project Demonstrates

A **production-grade** Terraform setup featuring:
- Modular DNS record management
- Cloudflare provider integration (v5)
- Zone settings management (HTTPS enforcement, redirect rules)
- CI/CD automation with GitHub Actions
- Secure secret management via OIDC (no long-lived credentials)
- GCS remote state storage

## Project Structure

```
briananderson-xyz-dns/
├── modules/
│   ├── dns_web/          # Web DNS records (A, CNAME)
│   ├── dns_mail/         # Mail DNS records (MX, DKIM, SPF, DMARC)
│   ├── dns_homelab/      # Homelab services
│   ├── dns_verification/ # Domain verification (TXT)
│   ├── api_worker/       # Cloudflare Workers
│   └── zone_settings/    # HTTPS, redirects
├── docs/                 # Documentation
├── .github/workflows/    # CI/CD pipeline
├── main.tf               # Root module orchestration
├── variables.tf          # Input variables
├── outputs.tf            # Outputs
├── backend.tf            # GCS remote state
├── provider.tf           # Cloudflare provider
└── terraform.tf          # Version constraints
```

## Quick Start

### 1. Install Prerequisites

```bash
# Terraform (>= 1.5.0)
# See https://developer.hashicorp.com/terraform/install
terraform --version
```

### 2. Setup Authentication

See [docs/secrets-setup.md](docs/secrets-setup.md) for detailed OIDC and secrets setup.

### 3. Local Development

```bash
# Create terraform.tfvars with your credentials (gitignored)
# See docs/secrets-setup.md for the required variables

terraform init
terraform plan
terraform apply
```

## Modules

| Module | Record Types | Purpose |
|--------|-------------|---------|
| **dns_web** | A, CNAME | Websites and web apps |
| **dns_mail** | MX, TXT (DKIM, SPF, DMARC) | Email routing and authentication |
| **dns_homelab** | A, AAAA | Homelab services |
| **dns_verification** | TXT | Domain verification |
| **api_worker** | Workers | Cloudflare Workers proxy |
| **zone_settings** | Zone settings, rulesets | HTTPS enforcement, www redirect |

## CI/CD Pipeline

GitHub Actions workflow automatically:

**On Pull Request:** Format check, validate, plan, comment on PR

**On Push to main:** All validation + `terraform apply`

## Security

- All sensitive values stored in GitHub Secrets
- OIDC authentication (no long-lived credentials)
- `.tfvars` files gitignored
- No secrets in repository history

## Documentation

| Document | Description |
|----------|-------------|
| [docs/architecture.md](docs/architecture.md) | Architecture, modules, and setup guide |
| [docs/secrets-setup.md](docs/secrets-setup.md) | GitHub Secrets and OIDC configuration |
| [docs/dns-records.md](docs/dns-records.md) | DNS records quick reference |

## Testing

```bash
# Validate DNS records
dig www.briananderson.xyz
dig briananderson.xyz MX
dig txt briananderson.xyz

# Terraform validation
terraform fmt -check
terraform validate
```

## License

MIT License - Use and modify freely for your own projects.
