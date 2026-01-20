# OpenID Connect (OIDC) Setup Guide

## 🎯 What is OIDC?

**OpenID Connect (OIDC)** is a secure authentication method that allows GitHub Actions to obtain temporary, short-lived credentials from GCP without storing long-lived secrets.

---

## 🔐 OIDC vs Service Account Keys

| Aspect | Service Account Key (Secret) | **OIDC (Recommended)** |
|--------|------------------------------|-------------------------|
| Security | ❌ Static key, long-lived | ✅ Temporary token, auto-rotated |
| Rotation | ⚠️ Manual, required | ✅ Automatic, per-workflow |
| Setup | ✅ One-time (create key) | ⚠️ One-time (configure federation) |
| Secrets | ❌ Requires GOOGLE_APPLICATION_CREDENTIALS | ✅ No GCP secrets needed |
| Lifetime | ∞ (until rotated) | ⏰ 15 minutes (per workflow) |
| Risk | ❌ Compromised key = full access | ✅ Short token window |
| **Best for** | ⚠️ Simple setups | ✅ Production, security-conscious |

---

## 🏗️ Architecture with OIDC

```
GitHub Actions Workflow
    ↓
Request OIDC Token (automatic)
    ↓
Exchange for GCP Access Token (15min lifetime)
    ↓
Access GCS Buckets (terraform-state-dev, terraform-state-prod)
    ↓
Terraform reads/writes state
```

### Benefits:

1. **No Long-Lived Secrets** - No static service account keys
2. **Auto-Rotation** - New token every workflow run
3. **Organization-Level Setup** - Configure once, all repos benefit
4. **Audit Trail** - Each authentication logged in GCP
5. **Reduced Attack Surface** - Compromised token = 15 min max access

---

## 📝 Step-by-Step Setup

### Step 1: Run OIDC Setup Script

```bash
./setup_oidc.sh
```

This script will:
1. ✅ Create service account: `terraform-state-sa`
2. ✅ Grant `storage.admin` role
3. ✅ Create Workload Identity Pool: `github-oidc-pool`
4. ✅ Create OIDC Provider: `github-provider`
5. ✅ Configure GitHub subject (org or repo level)
6. ✅ Allow service account impersonation

### Step 2: Choose GitHub Level

The script asks for:
- **Organization level** (recommended) - All repos in org can use OIDC
- **Repository level** - Only this repo can use OIDC

#### Organization Level (Recommended)

**Benefits:**
- ✅ One-time setup for entire org
- ✅ All new repos get OIDC automatically
- ✅ Consistent security policy across org
- ✅ Easier management

**Subject Pattern:**
```
repo:YOUR_ORG/*:ref:refs/heads/*
```

#### Repository Level

**Benefits:**
- ✅ Scoped to single repo
- ✅ More restrictive (good for highly sensitive projects)

**Subject Pattern:**
```
repo:YOUR_USERNAME/REPO:ref:refs/heads/main
```

### Step 3: Update Terraform Backend

**Replace:**
```bash
environments/dev/backend.tf
environments/prod/backend.tf
```

**With OIDC version:**
```bash
environments/dev/backend-oidc.tf
environments/prod/backend-oidc.tf
```

Or update existing backend.tf files to remove `credentials` parameter:
```hcl
terraform {
  backend "gcs" {
    bucket      = "terraform-state-dev"
    prefix      = "briananderson-xyz-dns"
    # credentials = "..."  # REMOVE THIS LINE
  }
}
```

When using OIDC, Terraform automatically reads `GOOGLE_CREDENTIALS` environment variable set by GitHub Actions.

### Step 4: Update GitHub Actions Workflow

**Use OIDC workflow:**
```bash
# Replace
.github/workflows/terraform.yml

# With
.github/workflows/terraform-oidc.yml
```

**Key differences:**
```yaml
# Added OIDC permissions
permissions:
  id-token: write  # Required for OIDC

# Use google-github-actions/auth action
- name: Authenticate to Google Cloud
  id: auth
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: projects/PROJECT_ID/locations/global/workloadIdentityPools/github-oidc-pool/providers/github-provider
      service_account: terraform-state-sa@PROJECT_ID.iam.gserviceaccount.com

# Pass credentials file path to Terraform
env:
  GOOGLE_CREDENTIALS: ${{ steps.auth.outputs.credentials_file_path }}
  # NO GOOGLE_APPLICATION_CREDENTIALS secret needed!
```

---

## 🔐 GitHub Organization-Level Setup

### Configure OIDC for Entire Organization

#### 1. GCP Side (One-Time)

Run setup script with organization:
```bash
./setup_oidc.sh
# Choose "org" level
# Enter your GitHub organization name
```

This creates a pool/provider that trusts your entire org:
```
Subject: repo:YOUR_ORG/*:ref:refs/heads/*
```

#### 2. GitHub Side (Optional)

If you want to restrict which repos can use OIDC:

**Option A: All Repos (Default)**
- No configuration needed
- All repos can request OIDC tokens

**Option B: Specific Repos**
Add repo-level policy:
```
Repo Settings → Actions → General
→ Workflow permissions → Require approvals? → [ ]
→ OIDC subject: repo:YOUR_ORG/REPO:ref:refs/heads/main
```

#### 3. Benefits

| Scenario | With Org-Level OIDC |
|----------|---------------------|
| New repo created? | ✅ Immediate access to GCS |
| Team member joins? | ✅ Their repos get OIDC |
| Need new project? | ✅ Just grant IAM role to SA |
| Rotation needed? | ✅ Automatic (no action needed) |

---

## 📋 Secrets Required

### With OIDC

You **only need** 2 secrets (not 3!):

| Secret | Value | Required? |
|--------|-------|-----------|
| `CLOUDFLARE_API_TOKEN` | Your Cloudflare token | ✅ Yes |
| `CLOUDFLARE_ZONE_ID` | Zone ID for briananderson.xyz | ✅ Yes |
| `GOOGLE_APPLICATION_CREDENTIALS` | Base64-encoded GCS key | ❌ **NO** |

**Why:** GCP credentials obtained automatically via OIDC token exchange.

### Without OIDC (Legacy)

| Secret | Value | Required? |
|--------|-------|-----------|
| `CLOUDFLARE_API_TOKEN` | Your Cloudflare token | ✅ Yes |
| `CLOUDFLARE_ZONE_ID` | Zone ID for briananderson.xyz | ✅ Yes |
| `GOOGLE_APPLICATION_CREDENTIALS` | Base64-encoded GCS key | ✅ Yes |

**Why:** Need long-lived service account key stored in secrets.

---

## 🚀 Quick Start with OIDC

### 1. Run Setup Script
```bash
./setup_oidc.sh
# Choose organization level
# Enter your GitHub org name
```

### 2. Update Terraform Backends
```bash
# Remove credentials parameter from backend.tf
# Or use backend-oidc.tf
```

### 3. Update GitHub Actions Workflow
```bash
# Use terraform-oidc.yml instead of terraform.yml
rm .github/workflows/terraform.yml
mv .github/workflows/terraform-oidc.yml .github/workflows/terraform.yml
```

### 4. Add GitHub Secrets

Only 2 secrets needed:
1. `CLOUDFLARE_API_TOKEN` = `YL6TH7zS_LLqnbrpnGS3hWnH9_pV-TfQO1_Z_zvo`
2. `CLOUDFLARE_ZONE_ID` = `806c2f971876ec222cf0a28bca4bd9a9`

### 5. Push to GitHub
```bash
git add .
git commit -m "Enable OIDC authentication for GitHub Actions"
git push origin main
```

---

## 🔍 Verify OIDC Setup

### Check Workload Identity Pool
```bash
gcloud iam workload-identity-pools describe github-oidc-pool \
  --location="global"
```

### Check OIDC Provider
```bash
gcloud iam workload-identity-pools providers describe github-provider \
  --location="global" \
  --workload-identity-pool="github-oidc-pool"
```

### Check Service Account
```bash
gcloud iam service-accounts describe terraform-state-sa@PROJECT_ID.iam.gserviceaccount.com
```

### Test Locally
```bash
# Export GCP project
export PROJECT_ID="your-project-id"

# Simulate OIDC token request
gcloud auth print-access-token \
  --impersonate-service-account="terraform-state-sa@${PROJECT_ID}.iam.gserviceaccount.com"
```

---

## 🎯 Best Practices

### 1. Use Organization-Level OIDC
- ✅ Configure once, benefit forever
- ✅ All repos get access automatically
- ✅ Consistent security policy

### 2. Use Specific IAM Roles
Instead of `storage.admin`, use:
- `roles/storage.objectAdmin` - For bucket operations
- `roles/storage.objectViewer` - For read-only access

### 3. Enable Audit Logging
```bash
gcloud logging sinks create oidc-audit-sink \
  --description="Sink for OIDC auth logs" \
  --destination="bigquery.googleapis.com/projects/PROJECT_ID/datasets/oidc_logs"

gcloud logging sinks update oidc-audit-sink \
  --log-filter='protoPayload.authenticationInfo.principalId="terraform-state-sa@PROJECT_ID.iam.gserviceaccount.com"'
```

### 4. Monitor Usage
```bash
# View recent OIDC authentications
gcloud logging read "protoPayload.authenticationInfo.principalId=\"terraform-state-sa@PROJECT_ID.iam.gserviceaccount.com\"" \
  --limit=10 \
  --format="table(timestamp,protoPayload.authenticationInfo.principalEmail,protoPayload.authenticationInfo.issuer)"
```

---

## 🔄 Migration from Secrets to OIDC

### Current State (Secrets)
- ✅ Working with `GOOGLE_APPLICATION_CREDENTIALS` secret
- ⚠️ Requires manual rotation
- ⚠️ Static key has indefinite lifetime

### Migrated State (OIDC)
- ✅ No GCP secrets needed
- ✅ Automatic token rotation
- ✅ Temporary 15-minute tokens
- ✅ Better audit trail

### Migration Steps

1. **Run OIDC setup script** - `./setup_oidc.sh`
2. **Create GCS buckets** - One-time setup
3. **Update backend files** - Remove `credentials` parameter
4. **Switch to OIDC workflow** - Use `terraform-oidc.yml`
5. **Remove old secret** - Delete `GOOGLE_APPLICATION_CREDENTIALS`
6. **Test workflow** - Push to GitHub and verify

---

## 🆚 Troubleshooting

### Error: "Unable to fetch token"
**Cause:** Subject mismatch between GCP and GitHub

**Fix:**
```bash
# Check configured subject
gcloud iam workload-identity-pools providers describe github-provider \
  --location="global" \
  --workload-identity-pool="github-oidc-pool" \
  --format="value(attributeCondition)"

# Ensure matches your GitHub org/repo
# Should be: assertion.sub=='repo:YOUR_ORG/*:ref:refs/heads/*'
```

### Error: "Permission denied"
**Cause:** Service account missing IAM role

**Fix:**
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:terraform-state-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
```

### Error: "No credentials found"
**Cause:** Terraform backend still configured for secrets

**Fix:**
```hcl
# Remove credentials line from backend.tf
terraform {
  backend "gcs" {
    bucket      = "terraform-state-dev"
    prefix      = "briananderson-xyz-dns"
    # credentials = "..."  # DELETE THIS LINE
  }
}
```

---

## 📊 Comparison Summary

| Feature | Service Account Key | OIDC |
|---------|-------------------|-------|
| Security | ⚠️ Static key | ✅ Auto-rotated tokens |
| Secrets in GitHub | 3 | 2 (GCP secret removed) |
| Token Lifetime | ∞ | 15 minutes |
| Attack Window | ∞ | 15 minutes |
| Organization Support | ❌ Per-repo | ✅ Org-wide |
| Setup Time | 5 minutes | 15 minutes |
| Maintenance | Manual rotation | Automatic |
| Audit Trail | Limited | Comprehensive |
| **Recommended For** | Simple projects | **Production, multi-repo, security-conscious** |

---

## ✅ Conclusion

**OIDC is the modern, secure approach** for GitHub Actions authentication to GCP.

**Key Advantages:**
1. ✅ No long-lived secrets
2. ✅ Organization-level setup (configure once!)
3. ✅ Automatic token rotation
4. ✅ Reduced attack surface
5. ✅ Better audit logging

**Perfect for:**
- Production infrastructure
- Multi-repo organizations
- Security-conscious teams
- "I live and breathe automation" portfolios

---

## 🚀 Next Steps

1. ✅ Run `./setup_oidc.sh` - Configure GCP OIDC
2. ✅ Choose organization level - Benefit all repos
3. ✅ Update Terraform backends - Remove credentials
4. ✅ Use OIDC workflow - Switch from secrets
5. ✅ Add 2 GitHub secrets - Cloudflare only
6. ✅ Push to GitHub - Verify OIDC works

**You're now using modern, secure OIDC authentication!** 🎉
