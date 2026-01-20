# Security and Secrets Management

## ⚠️ IMPORTANT: Never Commit Secrets

All sensitive data (API tokens, zone IDs, credentials) is **NOT** committed to Git.

---

## How to Provide Credentials

### Option 1: Environment Variables (Recommended)

Set environment variables before running Terraform:

```bash
export CLOUDFLARE_API_TOKEN="your_cloudflare_api_token_here"
export CLOUDFLARE_ZONE_ID="your_zone_id_here"

cd environments/prod
terraform plan
terraform apply
```

### Option 2: Local Variables File

Use `.tfvars.local` files (excluded from Git):

```bash
# Copy template
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars.local

# Edit with actual credentials
vim environments/prod/terraform.tfvars.local

# Terraform automatically uses .local file
cd environments/prod
terraform plan
```

**Files excluded from Git:**
- `*.tfvars` (variable files)
- `*.tfvars.local` (local override files)
- `*.auto.tfvars` (auto-loaded files)

### Option 3: GitHub Secrets (CI/CD)

Configure in your GitHub repository:

1. Go to: `Settings` → `Secrets and variables` → `Actions`
2. Add these secrets:
   - `CLOUDFLARE_API_TOKEN` = `your_cloudflare_api_token_here`
   - `CLOUDFLARE_ZONE_ID` = `your_zone_id_here`
   - `GOOGLE_APPLICATION_CREDENTIALS` = Base64-encoded GCS credentials

GitHub Actions workflow automatically uses these secrets.

---

## Files With Placeholders

These files contain **only placeholders** and are safe to commit:

- `terraform.tfvars.example` - Template file
- `environments/dev/terraform.tfvars` - Placeholders for dev
- `environments/prod/terraform.tfvars` - Placeholders for prod

**Never** replace placeholders with actual values in these files.

---

## Files With Actual Credentials (Local Only)

These files contain **actual credentials** and are **NOT** committed:

- `environments/prod/terraform.tfvars.local` - Production credentials (exists locally)
- `environments/dev/terraform.tfvars.local` - Development credentials (create if needed)
- `~/.cf-terraforming.yaml` - cf-terraforming config (in home directory)

---

## Best Practices

### 1. Never Commit Secrets
```bash
# Check what would be committed
git status

# Make sure no .tfvars or .local files are included
```

### 2. Use Environment Variables
```bash
# Set once in your shell
export CLOUDFLARE_API_TOKEN="your-token"
export CLOUDFLARE_ZONE_ID="your-zone-id"

# All Terraform commands will use these
terraform plan
terraform apply
```

### 3. Use GitHub Secrets for CI/CD
The `.github/workflows/terraform.yml` workflow automatically:
- Reads `CLOUDFLARE_API_TOKEN` from GitHub Secrets
- Reads `CLOUDFLARE_ZONE_ID` from GitHub Secrets
- Reads `GOOGLE_APPLICATION_CREDENTIALS` from GitHub Secrets

### 4. Rotate Credentials Regularly
- Regenerate API tokens periodically
- Update GitHub Secrets after rotation
- Update local .tfvars.local files after rotation

---

## Checking for Secrets

Before committing, verify no secrets are included:

```bash
# Search for tokens in git diff
git diff --cached | grep -i "token"

# Search for zone IDs in git diff
git diff --cached | grep -i "zone_id"

# Search for passwords/keys
git diff --cached | grep -iE "(password|secret|key)"
```

---

## GCS Credentials

For Terraform state backend, configure GCS credentials:

```bash
# Method 1: Use Application Default Credentials
export GOOGLE_APPLICATION_CREDENTIALS="~/.config/gcloud/application_default_credentials.json"

# Method 2: Base64 encode for GitHub Secrets
base64 -i ~/.config/gcloud/application_default_credentials.json
# Add output to GitHub Secrets as GOOGLE_APPLICATION_CREDENTIALS
```

---

## Example Workflow

### Local Development
```bash
# Set environment variables
export CLOUDFLARE_API_TOKEN="your-token"
export CLOUDFLARE_ZONE_ID="your-zone-id"

# Run Terraform
cd environments/prod
terraform plan
terraform apply
```

### CI/CD Pipeline
1. Configure GitHub Secrets
2. Push code changes
3. GitHub Actions automatically uses secrets
4. No secrets in git history

---

## Current Setup

✅ **Safe:** All `.tfvars` files use placeholders only
✅ **Safe:** `.gitignore` excludes all secret files
✅ **Safe:** GitHub Actions uses environment variables from secrets
✅ **Safe:** Actual credentials stored locally in `.tfvars.local` files

⚠️ **File to check:** `environments/prod/terraform.tfvars.local` - Contains actual credentials (not committed)
