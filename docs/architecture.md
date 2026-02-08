# Architecture

## Overview

This project manages DNS records, zone settings, and a Cloudflare Workers proxy for `briananderson.xyz` using Terraform with the Cloudflare provider (v5). Infrastructure state is stored in a GCS bucket, and CI/CD runs via GitHub Actions with OIDC authentication (no long-lived credentials).

## Module Breakdown

| Module | What It Manages | Key Resource Types |
|--------|----------------|-----------------|
| `dns_web` | Websites, apps, subdomains | A, CNAME |
| `dns_mail` | Gmail/Google Workspace email routing | MX, TXT (DKIM, SPF, DMARC) |
| `dns_homelab` | Self-hosted services | A, AAAA |
| `dns_verification` | Domain ownership proofs | TXT |
| `api_worker` | Cloudflare Workers proxy to Cloud Run | Worker scripts, routes, DNS |
| `zone_settings` | HTTPS enforcement, www redirect | Zone settings, redirect rulesets |

## Key Files

| File | Purpose |
|------|---------|
| `records.tf` | All DNS record and service definitions (locals) |
| `main.tf` | Wires modules together |
| `variables.tf` | Secret inputs only (API token, zone/account IDs) |
| `backend.tf` | GCS remote state configuration |

## Authentication Flow (CI/CD)

```
GitHub Actions
  -> Requests OIDC token from GitHub
  -> Exchanges for GCP access token (15 min lifetime) via Workload Identity Federation
  -> Authenticates to GCS for Terraform state
  -> Uses TF_VAR_ secrets for Cloudflare API access
```

No service account keys are stored anywhere. See [secrets-setup.md](secrets-setup.md) for configuration.

## State Management

- State is stored in a GCS bucket with versioning enabled for rollback
- State files contain sensitive data and are never committed to git
- All Terraform runs (local and CI) use the same remote state

## Adding a New DNS Record

1. Add the record definition to `records.tf` in the appropriate locals block
2. The locals are passed to modules in `main.tf` — see module `variables.tf` for the expected shape
3. Run `terraform plan` to preview, `terraform apply` to deploy
4. Or push to a branch and let CI/CD handle it

## Adding a New Module

1. Create `modules/<module_name>/` with `main.tf`, `variables.tf`, `outputs.tf`
2. Wire it up in `main.tf`
3. If the module needs record data, add a locals block in `records.tf`
4. If the module needs secrets, add variables to `variables.tf`

## Setting Up From Scratch

1. Install Terraform (>= 1.5.0)
2. Create a GCS bucket for state storage (see [secrets-setup.md](secrets-setup.md))
3. Configure GitHub Secrets (5 secrets required)
4. Create local `terraform.tfvars` with credentials
5. `terraform init && terraform plan && terraform apply`
