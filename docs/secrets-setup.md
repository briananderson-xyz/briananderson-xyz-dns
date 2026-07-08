# Secrets Setup

## GitHub Secrets

You need **8 secrets** in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `GCP_WIF_PROVIDER` | Full Workload Identity Federation provider resource name |
| `GCP_WIF_SA_EMAIL` | GCP service account email for state bucket access |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token |
| `CLOUDFLARE_ZONE_ID` | Cloudflare zone ID for briananderson.xyz |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare account ID |
| `MCP_GATEWAY_TOKEN` | Bearer token for the MCP gateway Worker |
| `ORIGIN_VERIFY_TOKEN_PROD` | Prod API Worker to Cloud Run origin verification token |
| `ORIGIN_VERIFY_TOKEN_DEV` | Dev API Worker to Cloud Run origin verification token |

## Cloudflare API Token Scopes

The API token needs these permissions:

| Scope | Level | Purpose |
|-------|-------|---------|
| DNS | Zone > Edit | Create/update/delete DNS records |
| Zone | Zone > Read | Read zone details |
| Zone Settings | Zone > Read | Manage Always Use HTTPS |
| Single Redirect | Zone > Edit | Manage www-to-root redirect rules |

## Local Development

Create a `terraform.tfvars` file in the project root (gitignored) with your credentials:

```hcl
cloudflare_api_token  = "<your-api-token>"
cloudflare_zone_id    = "<your-zone-id>"
cloudflare_account_id = "<your-account-id>"
mcp_gateway_bearer_token = "<your-mcp-gateway-token>"
origin_verify_token_prod = "<your-prod-origin-verify-token>"
origin_verify_token_dev  = "<your-dev-origin-verify-token>"
```

That's it — DNS record definitions live in `records.tf` (committed), so the tfvars only needs credentials and sensitive tokens.

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
