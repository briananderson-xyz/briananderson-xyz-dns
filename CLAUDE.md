# CLAUDE.md — Project Rules for Claude Code

## Critical Security Rules

### NEVER commit secrets
- NEVER include real API tokens, keys, passwords, zone IDs, project IDs, or any credential values in any file that will be committed to git
- Use placeholder values like `<your-api-token>`, `<your-zone-id>`, `<your-project-id>` in documentation and examples
- All sensitive values belong in:
  - GitHub Secrets (for CI/CD)
  - `*.tfvars` files (gitignored, for local use)
  - Environment variables
- Before any commit, scan all staged files for patterns: API keys, tokens, passwords, private keys, zone IDs, project IDs, service account emails with real values
- If you detect a secret in any file, STOP and alert the user immediately — do not commit

### NEVER reference CLAUDE.md or AGENTS.md in documentation
- Do not mention CLAUDE.md in README.md, docs/, or any other documentation files
- Do not mention AGENTS.md in README.md, docs/, or any other documentation files
- Do not reference these files in project structure diagrams or file listings
- These files are internal agent configuration only — they are not part of the project's public documentation

### Keep AGENTS.md in sync
- When modifying CLAUDE.md, always update AGENTS.md to reflect the same rules
- When modifying AGENTS.md, always update CLAUDE.md to reflect the same rules
- Both files must contain equivalent security rules at all times

## Project Context

This is a public-facing Terraform project managing DNS records for `briananderson.xyz` via Cloudflare. The repository is meant to be a portfolio showcase — all code is public, all secrets must stay out of git.

## Project Structure

- `modules/` — Reusable Terraform modules (dns_web, dns_mail, dns_homelab, dns_verification, api_worker, zone_settings, dns_tunnel, mcp_gateway)
- `docs/` — Project documentation
- `.github/workflows/` — CI/CD pipeline (single workflow: `terraform.yml`)
- Root `.tf` files — Terraform configuration (main, variables, outputs, backend, provider, records, terraform)

## Development Patterns

- Terraform 1.11+ with Cloudflare provider (v5)
- GCS backend for remote state storage (no native lock file — uses GCS object locking)
- OIDC authentication for CI/CD (no long-lived keys)
- DNS record definitions in `records.tf` (committed code — public data)
- Only secrets (API token, zone/account IDs, MCP gateway token) in `terraform.tfvars` (gitignored)

## CI/CD Nuances

- **Variable ↔ Secret mapping**: Every required Terraform variable without a default MUST have a corresponding `TF_VAR_*` env var in the workflow, backed by a GitHub Secret. Current secrets: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID`, `CLOUDFLARE_ACCOUNT_ID`, `MCP_GATEWAY_TOKEN`
- **Always use `-input=false`** on `terraform plan` in CI — prevents the plan from hanging silently if a variable is missing
- **Concurrency control**: The workflow uses a `concurrency` group per branch with `cancel-in-progress: true` to prevent parallel Terraform runs from causing state lock conflicts
- **State lock issues**: If a CI run is cancelled mid-plan/apply, it can leave a stale state lock on GCS. Fix with `terraform force-unlock <LOCK_ID>` locally
- **Terraform version**: CI version must match what the backend config requires. The `use_lockfile` GCS option requires TF 1.10+; currently removed from `backend.tf` since GCS doesn't fully support it yet

## File Safety Checklist (before any commit)

1. No `*.tfvars` files staged
2. No `*.tfstate` files staged
3. No `tfplan` files staged
4. No files containing real tokens, keys, or credentials
5. No `CLAUDE.md` or `AGENTS.md` referenced in docs
6. `.gitignore` is comprehensive and up to date
