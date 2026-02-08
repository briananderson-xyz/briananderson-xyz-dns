# Architecture

## Overview

This project manages DNS records for `briananderson.xyz` using Terraform with the Cloudflare provider. Infrastructure state is stored in GCS buckets, and CI/CD runs via GitHub Actions with OIDC authentication (no long-lived credentials).

## Environment Strategy

| Environment | Purpose | State Bucket |
|-------------|---------|-------------|
| **dev** | Testing new records before production | `terraform-state-dev` |
| **prod** | Live DNS records | `terraform-state-prod` |

Each environment has its own `terraform.tfvars` (gitignored) with record definitions and its own GCS state bucket.

## Module Breakdown

| Module | What It Manages | Key Record Types |
|--------|----------------|-----------------|
| `dns_web` | Websites, apps, subdomains | A, CNAME |
| `dns_mail` | Gmail/Google Workspace email routing | MX, TXT (DKIM, SPF, DMARC) |
| `dns_homelab` | Self-hosted services (Plex, NAS, VPN) | A, AAAA |
| `dns_verification` | Domain ownership proofs | TXT |
| `api_worker` | Cloudflare Workers | Worker scripts/routes |

## Authentication Flow (CI/CD)

```
GitHub Actions
  -> Requests OIDC token from GitHub
  -> Exchanges for GCP access token (15 min lifetime) via Workload Identity Federation
  -> Authenticates to GCS for Terraform state
  -> Uses CLOUDFLARE_API_TOKEN secret for DNS changes
```

No service account keys are stored anywhere. See [secrets-setup.md](secrets-setup.md) for configuration.

## Adding a New DNS Record

1. Edit the appropriate `terraform.tfvars` in `environments/dev/` or `environments/prod/`
2. The tfvars map to module variables — see module `variables.tf` for the expected shape
3. Run `terraform plan` to preview, `terraform apply` to deploy
4. Or just push to a branch and let CI/CD handle it

## Adding a New Module

1. Create `modules/<module_name>/` with `main.tf`, `variables.tf`, `outputs.tf`
2. Wire it up in the root `main.tf`
3. Add variables to root `variables.tf` and pass them through
4. Add entries to `environments/*/terraform.tfvars`

## State Management

- State is stored in GCS with versioning enabled for rollback
- Each environment has a separate bucket — they never share state
- State files contain sensitive data and are never committed to git

## Setting Up From Scratch

1. Install Terraform (>= 1.5.0)
2. Create GCS buckets for state storage (see [secrets-setup.md](secrets-setup.md))
3. Configure GitHub Secrets (6 secrets required)
4. Optionally import existing Cloudflare records with `cf-terraforming`
5. `terraform init && terraform plan && terraform apply`
