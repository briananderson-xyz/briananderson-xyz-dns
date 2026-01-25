# GitHub Secrets Setup

## 🔐 Secrets You Need to Add

You need **5 secrets** at GitHub organization level:

| Secret | Value | Description |
|--------|-------|-------------|
| `GCP_PROJECT_ID` | Your actual GCP project ID | Project containing Terraform state buckets |
| `GCP_REGION` | Your GCP region (e.g., us-west4) | Region for GCS buckets |
| `GCP_WIF_PROVIDER` | Full workload identity provider resource name | OIDC provider for GitHub Actions |
| `GCP_WIF_SA_EMAIL` | `terraform-state-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com` | Service account for Terraform state |
| `CLOUDFLARE_API_TOKEN` | Your Cloudflare API token | For Cloudflare DNS management |
| `CLOUDFLARE_ZONE_ID` | `your_zone_id_here` | Zone ID for briananderson.xyz |

## 📝 How to Add Secrets

### Step 1: Go to GitHub Organization Settings
```
https://github.com/organizations/YOUR_ORG/settings/secrets/actions
```

### Step 2: Add Organization-Level Secrets (5 total)

**Secret #1: GCP_PROJECT_ID**
```
Name: GCP_PROJECT_ID
Value: your-actual-gcp-project-id
Description: GCP project ID containing Terraform state buckets
```

**Secret #2: GCP_REGION**
```
Name: GCP_REGION
Value: your-gcp-region
Description: GCP region for Terraform state buckets (e.g., us-west4)
```

**Secret #3: GCP_WIF_PROVIDER**
```
Name: GCP_WIF_PROVIDER
Value: projects/YOUR_PROJECT_ID/locations/global/workloadIdentityPools/github-oidc-pool/providers/github-provider
Description: Full workload identity provider resource name for GitHub Actions OIDC
```

**Secret #4: GCP_WIF_SA_EMAIL**
```
Name: GCP_WIF_SA_EMAIL
Value: terraform-state-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
Description: Service account email for Terraform state management (match your actual GCP setup)
```

**Secret #5: CLOUDFLARE_API_TOKEN**
```
Name: CLOUDFLARE_API_TOKEN
Value: your_cloudflare_api_token_here
Description: Cloudflare API token with DNS:Edit and Zone:Read scopes
```

**Secret #6: CLOUDFLARE_ZONE_ID**
```
Name: CLOUDFLARE_ZONE_ID
Value: your_zone_id_here
Description: Zone ID for briananderson.xyz
```

### Step 3: Add Repository-Level Secrets (2 optional)

If you prefer repository-level secrets instead of organization-level:

**Secret #1: CLOUDFLARE_API_TOKEN**
```
Name: CLOUDFLARE_API_TOKEN
Value: your_cloudflare_api_token_here
```

**Secret #2: CLOUDFLARE_ZONE_ID**
```
Name: CLOUDFLARE_ZONE_ID
Value: your_zone_id_here
```

---

## 🔍 What Changed in Latest Update

### Fixed Workload Identity Provider Format

**Before (Error):**
```yaml
workload_identity_provider: ${{ secrets.GCP_WIF_PROVIDER }}
```
This caused error: "invalid value for audience"

**After (Fixed):**
```yaml
workload_identity_provider: projects/${{ env.GCP_PROJECT_ID }}/locations/global/workloadIdentityPools/${{ env.GCP_POOL_ID }}/providers/${{ env.GCP_PROVIDER_ID }}
```

This is the **correct full resource name** that GitHub Actions expects.

---

## 🎯 Why Multiple Secrets?

### Flexibility
- Easy to update project ID if you create a new one
- Easy to update pool/provider names if you change them
- Clear what each secret controls

### Security
- Granular access control per secret
- Easier to audit and rotate individual secrets
- Clear separation of concerns

### Troubleshooting
- If OIDC fails, you know which component is wrong
- Can test with different pool/provider without changing everything
- Clear error messages point to specific component

---

## 🚀 After Adding Secrets

### GitHub Actions Workflow Will:
1. ✅ Construct full resource name from 4 components
2. ✅ Request OIDC token from GitHub
3. ✅ Exchange for GCP access token (15 min)
4. ✅ Authenticate to GCS buckets
5. ✅ Initialize Terraform state
6. ✅ Plan and apply changes

### Security Benefits
- ✅ No long-lived GCP credentials in GitHub
- ✅ Automatic token rotation (every workflow run)
- ✅ Organization-level configuration
- ✅ Reduced attack surface (15-min tokens)

---

## 📋 Complete Secrets Summary

### Organization-Level (6 secrets)
1. ✅ `GCP_PROJECT_ID` - Your GCP project ID
2. ✅ `GCP_POOL_ID` - `github-oidc-pool`
3. ✅ `GCP_PROVIDER_ID` - `github-provider`
4. ✅ `GCP_WIF_SA_EMAIL` - `terraform-state-sa@PROJECT_ID.iam.gserviceaccount.com`
5. ✅ `CLOUDFLARE_API_TOKEN` - Cloudflare API token
6. ✅ `CLOUDFLARE_ZONE_ID` - Zone ID for briananderson.xyz

### Repository-Level (2 secrets, optional if using org-level)
7. ✅ `CLOUDFLARE_API_TOKEN` - Same as above
8. ✅ `CLOUDFLARE_ZONE_ID` - Same as above

---

## ✅ What This Fixes

**Error:** "invalid value for audience" for workload_identity_provider

**Cause:** Workflow was using partial resource name instead of full resource name

**Solution:** Workflow now constructs full resource name from components:
```
projects/${GCP_PROJECT_ID}/locations/global/workloadIdentityPools/${GCP_POOL_ID}/providers/${GCP_PROVIDER_ID}
```

**Result:** GitHub Actions will correctly identify and authenticate to your OIDC provider.

---

## 🎯 Next Steps

1. Add 6 secrets at GitHub organization level (5 min)
2. Watch GitHub Actions workflow run (2 min)
3. Verify: "Authentication: ✓" in workflow logs
4. Verify: Terraform init succeeds (no GCS credentials errors)
5. Check Terraform plan output (should show 0 to add/change)

---

## 📝 Notes

- Organization-level secrets are recommended for OIDC
- Repository-level Cloudflare secrets work with org-level OIDC
- All GCP authentication uses OIDC (no service account key secrets needed)
- Each secret has a clear, specific purpose
- Full resource name format matches GitHub Actions expectations
