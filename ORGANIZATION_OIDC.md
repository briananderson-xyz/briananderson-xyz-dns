# GitHub Organization-Level OIDC Setup

## 🎯 Quick Answer: Yes, OIDC Can Be Configured at Org Level!

When you configure Workload Identity Federation in GCP with a **GitHub Organization subject** (`repo:YOUR_ORG/*:ref:refs/heads/*`), **every repository in your organization** can use OIDC authentication without adding secrets to individual repos.

---

## 🏗️ Architecture

```
GitHub Organization (your-org)
    ↓ (all repos)
Any Repository Can Request OIDC Token
    ↓ (automatic exchange)
Temporary GCP Access Token (15min)
    ↓
GCS Buckets (terraform-state-dev, terraform-state-prod)
```

---

## 📋 Complete Setup Checklist

### Prerequisites
- [ ] Google Cloud project created
- [ ] GitHub organization exists
- [ ] `gcloud` CLI installed and authenticated

### Step 1: Run OIDC Setup Script
```bash
./setup_oidc.sh
```

This script will:
1. ✅ Create service account: `terraform-state-sa`
2. ✅ Grant `storage.admin` role to service account
3. ✅ Create Workload Identity Pool: `github-oidc-pool`
4. ✅ Create OIDC Provider: `github-provider`
5. ✅ Configure GitHub subject (organization or repository level)
6. ✅ Allow service account impersonation via OIDC

**When prompted:**
- Choose **"org"** for organization-level setup (recommended!)
- Enter your GitHub organization name
- Script configures: `repo:YOUR_ORG/*:ref:refs/heads/*`

### Step 2: Create GCS Buckets
```bash
gsutil mb -l us-central1 gs://terraform-state-dev
gsutil mb -l us-central1 gs://terraform-state-prod
```

### Step 3: Update Terraform Backends
Remove `credentials` parameter from backend.tf files:

**Option A: Use new OIDC backend files**
```bash
mv environments/dev/backend-oidc.tf environments/dev/backend.tf
mv environments/prod/backend-oidc.tf environments/prod/backend.tf
```

**Option B: Edit existing backend.tf files**
```bash
# Edit environments/dev/backend.tf
vim environments/dev/backend.tf

# Remove credentials line:
terraform {
  backend "gcs" {
    bucket      = "terraform-state-dev"
    prefix      = "briananderson-xyz-dns"
    # credentials = "..."  # DELETE THIS LINE
  }
}
```

### Step 4: Update GitHub Actions Workflow
```bash
# Replace with OIDC version
rm .github/workflows/terraform.yml
mv .github/workflows/terraform-oidc.yml .github/workflows/terraform.yml
```

### Step 5: Add GitHub Secrets (Only 2 needed!)

At **GitHub Organization level** (recommended):
```
Organization Settings → Secrets and variables → Actions → New organization secret
```

Add only these 2 secrets:
1. `CLOUDFLARE_API_TOKEN` = `YL6TH7zS_LLqnbrpnGS3hWnH9_pV-TfQO1_Z_zvo`
2. `CLOUDFLARE_ZONE_ID` = `806c2f971876ec222cf0a28bca4bd9a9`

**No GOOGLE_APPLICATION_CREDENTIALS secret needed!** ✅

Or add at repository level (also works):
```
Your Repo → Settings → Secrets and variables → Actions
```

### Step 6: Push to GitHub
```bash
git add .
git commit -m "Enable OIDC authentication for GitHub Actions"
git push origin main
```

---

## 🎯 Organization-Level Benefits

### Configure Once, Use Forever

| Scenario | With Org-Level OIDC |
|-----------|---------------------|
| New repo created? | ✅ Immediately can access GCS (no secret setup!) |
| Team member joins? | ✅ Their repos inherit OIDC access |
| Multiple repos in org? | ✅ All use same OIDC provider (consistent security) |
| Need new project? | ✅ Just grant IAM role to service account |

### Security Benefits

1. **Consistent Policy** - All repos use same OIDC provider
2. **Easier Auditing** - Single source of GCP access logs
3. **Reduced Attack Surface** - One attack vector to monitor
4. **Simplified Onboarding** - New repos = instant OIDC access

---

## 📁 Files to Commit

All these are safe (no secrets):
- `setup_oidc.sh` - OIDC setup script
- `.github/workflows/terraform-oidc.yml` - OIDC workflow
- `environments/dev/backend-oidc.tf` - OIDC backend
- `environments/prod/backend-oidc.tf` - OIDC backend
- `OIDC_SETUP.md` - Complete OIDC guide
- This file - Organization-level setup guide

---

## 🔍 Verify OIDC Works

### 1. Check GitHub Actions Logs
Go to: `Your Repo → Actions → Latest workflow run → Job → Setup step`

Look for:
```
Authentication: ✓
```

### 2. Check Terraform Init Logs
Look for:
```
Backend reinitialization...
Successfully configured the backend "gcs"
```

### 3. Check GCP Logs
```bash
# View recent OIDC authentications
gcloud logging read \
  "protoPayload.authenticationInfo.principalId=\"terraform-state-sa@PROJECT_ID.iam.gserviceaccount.com\"" \
  --limit=10
```

---

## 🆚 Comparison: Secrets vs OIDC

| Feature | Service Account Key | **OIDC (Recommended)** |
|---------|-------------------|------------------------|
| GCP Secret | `GOOGLE_APPLICATION_CREDENTIALS` | **None needed** ✅ |
| Total GitHub Secrets | 3 | 2 (Cloudflare only) |
| Token Lifetime | ∞ | 15 minutes ⏰ |
| Auto-Rotation | ❌ | ✅ |
| Organization Support | ❌ Per-repo | ✅ **Org-wide** |
| Security | ⚠️ | ✅ |
| Attack Window | ∞ | 15 minutes |
| Best For | Simple setups | Production, multi-repo orgs |

---

## 📝 Example: New Repo in Org

### Without OIDC
1. Create new repo
2. Generate service account key
3. Base64 encode key
4. Add `GOOGLE_APPLICATION_CREDENTIALS` secret to repo
5. Configure GitHub Actions workflow
6. Test and verify

**Time: ~20 minutes per repo**

### With OIDC (Already Configured at Org Level!)
1. Create new repo
2. Add GitHub Actions workflow with OIDC
3. Add Cloudflare secrets (if needed)
4. Push and run

**Time: ~5 minutes** ✅

---

## 🎯 Summary

### Yes, You Can Configure OIDC at GitHub Organization Level!

**Benefits:**
- ✅ One-time setup for entire organization
- ✅ All repos get OIDC access automatically
- ✅ No GCP secrets in any repo
- ✅ Consistent security policy across org
- ✅ Better audit trail
- ✅ Automatic token rotation

**What You Still Need:**
- ⚠️ 2 GitHub secrets: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID`
- ✅ No `GOOGLE_APPLICATION_CREDENTIALS` secret needed

**Perfect for "I live and breathe automation" portfolio!** 🚀

---

## 🚀 Quick Start

```bash
# 1. Run OIDC setup
./setup_oidc.sh
# Choose "org" level
# Enter your GitHub org name

# 2. Create GCS buckets
gsutil mb -l us-central1 gs://terraform-state-dev
gsutil mb -l us-central1 gs://terraform-state-prod

# 3. Switch to OIDC workflow
rm .github/workflows/terraform.yml
mv .github/workflows/terraform-oidc.yml .github/workflows/terraform.yml

# 4. Add GitHub secrets at org level
# Only CLOUDFLARE_API_TOKEN and CLOUDFLARE_ZONE_ID needed!

# 5. Push
git add .
git commit -m "Enable organization-level OIDC"
git push origin main
```

**Your entire organization can now use secure OIDC authentication!** 🎉
