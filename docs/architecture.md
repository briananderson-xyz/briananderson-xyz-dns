# Architecture

## Overview

This project manages DNS records and zone settings for `briananderson.xyz` using Terraform with the Cloudflare provider (v5). Infrastructure state is stored in a GCS bucket, and CI/CD runs via GitHub Actions with OIDC authentication (no long-lived credentials).

## Module Breakdown

| Module | What It Manages | Key Resource Types |
|--------|----------------|-----------------|
| `dns_web` | Websites, apps, subdomains | A, CNAME |
| `dns_mail` | Gmail/Google Workspace email routing | MX, TXT (DKIM, SPF, DMARC) |
| `dns_homelab` | Self-hosted services (Plex, NAS, VPN) | A, AAAA |
| `dns_verification` | Domain ownership proofs | TXT |
| `api_worker` | Cloudflare Workers proxy | Worker scripts/routes |
| `zone_settings` | HTTPS enforcement, www redirect | Zone settings, redirect rulesets |

## Authentication Flow (CI/CD)

```
GitHub Actions
  -> Requests OIDC token from GitHub
  -> Exchanges for GCP access token (15 min lifetime) via Workload Identity Federation
  -> Authenticates to GCS for Terraform state
  -> Uses TF_VAR_cloudflare_api_token secret for DNS changes
```

No service account keys are stored anywhere. See [secrets-setup.md](secrets-setup.md) for configuration.

## State Management

- State is stored in a GCS bucket with versioning enabled for rollback
- State files contain sensitive data and are never committed to git
- All Terraform runs (local and CI) use the same remote state

## Adding a New DNS Record

1. Edit `terraform.tfvars` (gitignored) with the new record definition
2. The tfvars map to module variables — see module `variables.tf` for the expected shape
3. Run `terraform plan` to preview, `terraform apply` to deploy
4. Or push to a branch and let CI/CD handle it

## Adding a New Module

1. Create `modules/<module_name>/` with `main.tf`, `variables.tf`, `outputs.tf`
2. Wire it up in the root `main.tf`
3. Add variables to root `variables.tf` and pass them through
4. Add entries to `terraform.tfvars`

## Setting Up From Scratch

1. Install Terraform (>= 1.5.0)
2. Create a GCS bucket for state storage (see [secrets-setup.md](secrets-setup.md))
3. Configure GitHub Secrets (7 secrets required)
4. Optionally import existing Cloudflare records with `terraform import`
5. `terraform init && terraform plan && terraform apply`
