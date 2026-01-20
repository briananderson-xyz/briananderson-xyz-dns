# GitHub Secrets Setup

## 🔐 Required Secrets

You only need 2 GitHub secrets (GCP auth uses org-level OIDC):

| Secret | Value | Where to Add |
|--------|-------|--------------|
| `CLOUDFLARE_API_TOKEN` | Your Cloudflare API token | Repository Settings → Secrets and variables → Actions |
| `CLOUDFLARE_ZONE_ID` | Zone ID for briananderson.xyz | Repository Settings → Secrets and variables → Actions |

## 📝 How to Add Secrets

1. Go to: `https://github.com/briananderson-xyz/briananderson-xyz-dns/settings/secrets/actions`
2. Click: "New repository secret"
3. Add each secret above
4. Click: "Add secret"

## ✅ Organization-Level Variables (Already Set)

These are configured at the GitHub organization level:
- `GCP_WIF_PROVIDER`
- `GCP_WIF_SA_EMAIL`

No action needed - these are inherited automatically!

---

## 🎯 Quick Reference

### Repository-Level Secrets (You Add These)
```
CLOUDFLARE_API_TOKEN = [Your Cloudflare API token]
CLOUDFLARE_ZONE_ID = [Your Zone ID for briananderson.xyz]
```

### Organization-Level Variables (Already Set)
```
GCP_WIF_PROVIDER = [GCP Workload Identity Provider]
GCP_WIF_SA_EMAIL = [GCP Service Account Email]
```

---

## 🔍 Verification

After adding secrets, GitHub Actions will automatically use them. Watch the workflow run to verify OIDC authentication succeeds.

---

## 🚀 Next Steps

1. Add 2 GitHub secrets (CLOUDFLARE_API_TOKEN, CLOUDFLARE_ZONE_ID)
2. Watch GitHub Actions workflow run
3. Verify OIDC authentication works
4. Check Terraform plan output
