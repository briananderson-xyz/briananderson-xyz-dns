# GitHub Secrets Setup

## Secrets You Need to Add

You need **7 secrets** in your GitHub repository (or organization):

| Secret | Value | Description |
|--------|-------|-------------|
| `GCP_WIF_PROVIDER` | Full WIF provider resource name | Workload Identity Federation provider |
| `GCP_WIF_SA_EMAIL` | Your service account email | e.g. `terraform-state-sa@<project>.iam.gserviceaccount.com` |
| `CLOUDFLARE_API_TOKEN` | Your Cloudflare API token | Token with DNS:Edit, Zone:Read, Zone Settings, Single Redirect scopes |
| `CLOUDFLARE_ZONE_ID` | Your Cloudflare zone ID | Zone ID from Cloudflare dashboard |
| `CLOUDFLARE_ACCOUNT_ID` | Your Cloudflare account ID | Account ID from Cloudflare dashboard |
| `GCP_PROJECT_ID` | Your GCP project ID | Project containing Terraform state bucket |
| `GCP_POOL_ID` | Your Workload Identity Pool name | e.g. `github-oidc-pool` |

## Cloudflare API Token Scopes

The API token needs these permissions:

| Scope | Level | Purpose |
|-------|-------|---------|
| DNS | Zone > Edit | Create/update/delete DNS records |
| Zone | Zone > Read | Read zone details |
| Zone Settings | Zone > Read | Manage Always Use HTTPS |
| Single Redirect | Zone > Edit | Manage www-to-root redirect rules |

## How to Add Secrets

### Step 1: Go to GitHub Repository Settings
```
https://github.com/<owner>/<repo>/settings/secrets/actions
```

### Step 2: Add Each Secret

Use placeholder-free real values for each secret. All values are encrypted at rest by GitHub.

## Local Development

For local `terraform plan`/`apply`, create a `terraform.tfvars` file in the project root (gitignored):

```hcl
cloudflare_api_token  = "<your-api-token>"
cloudflare_zone_id    = "<your-zone-id>"
cloudflare_account_id = "<your-account-id>"

web_records = {
  # your records here
}

mail_records = {
  # your records here
}
```

## Workload Identity Federation (OIDC)

The CI/CD workflow uses OIDC to authenticate to GCP — no long-lived service account keys required.

```
GitHub Actions
  -> Requests OIDC token
  -> Exchanges for GCP access token (15 min lifetime)
  -> Authenticates to GCS for state storage
```

### Security Benefits
- No long-lived GCP credentials in GitHub
- Automatic token rotation (every workflow run)
- Reduced attack surface (15-min tokens)
