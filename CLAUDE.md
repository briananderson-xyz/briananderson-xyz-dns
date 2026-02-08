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

- `modules/` — Reusable Terraform modules (dns_web, dns_mail, dns_homelab, dns_verification, api_worker)
- `environments/` — Environment-specific configs (dev, prod)
- `docs/` — Project documentation
- `.github/workflows/` — CI/CD pipelines
- Root `.tf` files — Root module orchestration

## Development Patterns

- Terraform with Cloudflare provider
- GCS backend for state storage
- OIDC authentication for CI/CD (no long-lived keys)
- Environment separation: dev and prod
- All DNS record values passed via `terraform.tfvars` (gitignored)

## File Safety Checklist (before any commit)

1. No `*.tfvars` files staged
2. No `*.tfstate` files staged
3. No `tfplan` files staged
4. No files containing real tokens, keys, or credentials
5. No `CLAUDE.md` or `AGENTS.md` referenced in docs
6. `.gitignore` is comprehensive and up to date
