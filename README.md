# briananderson-xyz-dns

Modular Terraform project to manage all DNS records for `briananderson.xyz` via Cloudflare.

## What This Project Demonstrates

A **production-grade** Terraform setup featuring:
- Modular DNS record management
- Environment separation (dev/prod)
- Cloudflare provider integration
- CI/CD automation with GitHub Actions
- Secure secret management via OIDC
- Terraform best practices (validation, modules)

## Project Structure

```
briananderson-xyz-dns/
├── modules/
│   ├── dns_web/          # Web DNS records (A, CNAME)
│   ├── dns_mail/         # Mail DNS records (MX, DKIM)
│   ├── dns_homelab/      # Homelab services (Plex, NAS)
│   ├── dns_verification/ # Domain verification (TXT)
│   └── api_worker/       # Cloudflare Workers
├── environments/
│   ├── dev/              # Development environment
│   └── prod/             # Production environment
├── docs/                 # Documentation
├── .github/workflows/    # CI/CD pipeline
├── main.tf               # Root module orchestration
├── variables.tf          # Global variables
├── outputs.tf            # Global outputs
├── data.tf               # Data sources
└── provider.tf           # Cloudflare provider
```

## Quick Start

### 1. Install Prerequisites

```bash
# Terraform (>= 1.5.0)
# See https://developer.hashicorp.com/terraform/install
terraform --version
```

### 2. Setup Authentication

See [docs/secrets-setup.md](docs/secrets-setup.md) for detailed OIDC setup.

GitHub secrets needed:
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ZONE_ID`
- `GCP_PROJECT_ID`
- `GCP_POOL_ID`
- `GCP_PROVIDER_ID`
- `GCP_WIF_SA_EMAIL`

### 3. Initialize & Apply

```bash
# Development
cd environments/dev
terraform init && terraform plan && terraform apply

# Production
cd environments/prod
terraform init && terraform plan && terraform apply
```

## Architecture

### Environments

| Environment | Purpose | State Storage |
|-------------|---------|---------------|
| **dev** | Web application testing | GCS bucket (dev) |
| **prod** | Production services | GCS bucket (prod) |

### Modules

| Module | Record Types | Purpose |
|--------|-------------|---------|
| **dns_web** | A, CNAME | Websites and web apps |
| **dns_mail** | MX, TXT (DKIM, SPF, DMARC) | Email routing and authentication |
| **dns_homelab** | A, AAAA | Homelab services |
| **dns_verification** | TXT | Domain verification |
| **api_worker** | Workers | Cloudflare Workers |

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
