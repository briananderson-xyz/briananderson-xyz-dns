# GitHub Secrets Setup

## Secrets You Need to Add

You need **6 secrets** at GitHub organization level:

| Secret | Value | Description |
|--------|-------|-------------|
| `GCP_PROJECT_ID` | Your actual GCP project ID | Project containing Terraform state buckets |
| `GCP_POOL_ID` | Your Workload Identity Pool name | e.g. `github-oidc-pool` |
| `GCP_PROVIDER_ID` | Your OIDC Provider name | e.g. `github-provider` |
| `GCP_WIF_SA_EMAIL` | Your service account email | e.g. `terraform-state-sa@PROJECT_ID.iam.gserviceaccount.com` |
| `CLOUDFLARE_API_TOKEN` | Your Cloudflare API token | Token with DNS:Edit and Zone:Read scopes |
| `CLOUDFLARE_ZONE_ID` | Your Cloudflare zone ID | Zone ID from Cloudflare dashboard |

## How to Add Secrets

### Step 1: Go to GitHub Organization Settings
```
https://github.com/organizations/YOUR_ORG/settings/secrets/actions
```

### Step 2: Add Organization-Level Secrets

**Secret #1: GCP_PROJECT_ID**
```
Name: GCP_PROJECT_ID
Value: <your-gcp-project-id>
```

**Secret #2: GCP_POOL_ID**
```
Name: GCP_POOL_ID
Value: <your-workload-identity-pool-name>
```

**Secret #3: GCP_PROVIDER_ID**
```
Name: GCP_PROVIDER_ID
Value: <your-oidc-provider-name>
```

**Secret #4: GCP_WIF_SA_EMAIL**
```
Name: GCP_WIF_SA_EMAIL
Value: <your-service-account>@<your-project-id>.iam.gserviceaccount.com
```

**Secret #5: CLOUDFLARE_API_TOKEN**
```
Name: CLOUDFLARE_API_TOKEN
Value: <your-cloudflare-api-token>
```

**Secret #6: CLOUDFLARE_ZONE_ID**
```
Name: CLOUDFLARE_ZONE_ID
Value: <your-cloudflare-zone-id>
```

## Workload Identity Provider Format

The GitHub Actions workflow constructs the full resource name from components:
```
projects/${GCP_PROJECT_ID}/locations/global/workloadIdentityPools/${GCP_POOL_ID}/providers/${GCP_PROVIDER_ID}
```

## Why Multiple Secrets?

### Flexibility
- Easy to update individual components without changing everything
- Clear what each secret controls

### Security
- Granular access control per secret
- Easier to audit and rotate individual secrets
- Clear separation of concerns

### Troubleshooting
- If OIDC fails, you know which component is wrong
- Can test with different pool/provider without changing everything

## After Adding Secrets

### GitHub Actions Workflow Will:
1. Construct full resource name from components
2. Request OIDC token from GitHub
3. Exchange for GCP access token (15 min lifetime)
4. Authenticate to GCS buckets
5. Initialize Terraform state
6. Plan and apply changes

### Security Benefits
- No long-lived GCP credentials in GitHub
- Automatic token rotation (every workflow run)
- Organization-level configuration
- Reduced attack surface (15-min tokens)
