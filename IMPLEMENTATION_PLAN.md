# Implementation Plan: briananderson-xyz-dns

## Architecture Overview

**Objective:** Modular Terraform project to manage DNS records for `briananderson.xyz` via Cloudflare

**Environment Strategy:**
- **dev**: Web application testing (dev-www, test-app, staging subdomains)
- **prod**: Production websites + Plex + Mail + Verification records

**State Storage:** Two separate GCS buckets
- `terraform-state-dev` → dev environment state
- `terraform-state-prod` → production environment state

**Tech Stack:**
- Terraform (Cloudflare provider ~v5)
- HCL configuration
- GitHub Actions for CI/CD
- cf-terraforming for importing existing records

## Complete Project Structure

```
briananderson-xyz-dns/
├── IMPLEMENTATION_PLAN.md          # This document
├── modules/
│   ├── dns_web/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── dns_mail/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── dns_homelab/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── dns_verification/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── backend.tf
│   │   ├── terraform.tfvars
│   │   └── README.md
│   └── prod/
│       ├── backend.tf
│       ├── terraform.tfvars
│       └── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── data.tf
├── provider.tf
├── terraform.tf
├── terraform.tfvars.example
├── .gitignore
├── .terraform-version
├── .tflint.hcl
└── .github/
    └── workflows/
        └── terraform.yml
```

## Phase 1: Prerequisites

### Install Required Tools

```bash
# Install Terraform (>= 1.5)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform --version

# Install cf-terraforming for importing existing records
wget https://github.com/cloudflare/cf-terraforming/releases/download/v0.11.0/cf-terraforming_0.11.0_linux_amd64.tar.gz
tar -xzf cf-terraforming_0.11.0_linux_amd64.tar.gz
sudo mv cf-terraforming /usr/local/bin/
sudo chmod +x /usr/local/bin/cf-terraforming

# Verify installation
cf-terraforming --version

# Install tflint for linting
go install github.com/terraform-linters/tflint/cmd/tflint@latest
```

### Create GCS Buckets

```bash
# Set your project ID
export PROJECT_ID="your-gcp-project-id"

# Create dev state bucket
gsutil mb -l us-central1 -p $PROJECT_ID gs://terraform-state-dev
gsutil versioning set on gs://terraform-state-dev

# Create prod state bucket
gsutil mb -l us-central1 -p $PROJECT_ID gs://terraform-state-prod
gsutil versioning set on gs://terraform-state-prod
```

### Get Cloudflare Credentials

```bash
# Get your Cloudflare Zone ID from dashboard
# https://dash.cloudflare.com/ -> Select briananderson.xyz -> Overview -> Zone ID

# Create Cloudflare API Token with scopes:
# - Zone - DNS - Edit
# - Zone - Zone - Read
# Store in environment variable
export CLOUDFLARE_API_TOKEN="your-api-token"
export CLOUDFLARE_ZONE_ID="your-zone-id"
```

## Phase 2: Import Existing Records

### Export Existing Cloudflare Records

```bash
# Export all DNS records from Cloudflare
cf-terraforming import --resource-type "cloudflare_record" --zone $CLOUDFLARE_ZONE_ID > imported_records.tf

# Review the exported file
cat imported_records.tf
```

### Analyze Existing Records

Categorize your existing records:
- Web: A, CNAME records for websites
- Mail: MX, SPF, DKIM, DMARC records
- Homelab: Plex record
- Verification: TXT records for services

**Example categorization:**
```
Web: www, blog, portfolio, app
Mail: @ (MX), @ (SPF), google._domainkey (DKIM), _dmarc
Homelab: plex
Verification: google-site-verification, @ (other TXT records)
```

## Phase 3: Initialize and Apply

### Initialize Development Environment

```bash
cd environments/dev
terraform init
```

### Import Existing Records to Terraform State

**Option A: Import All Records (Recommended for first-time setup)**
```bash
# From root directory
terraform import cloudflare_dns_record.web["www"] "<zone_id>/<record_id>"
terraform import cloudflare_dns_record.mx[0] "<zone_id>/<record_id>"
# Repeat for each record...
```

**Option B: Use Imported File as Reference**
```bash
# Use imported_records.tf from Phase 2 as reference
# Manually refactor into module structure based on categories
# Then initialize with new structure
```

### Plan and Apply Development Environment

```bash
cd environments/dev
terraform plan
terraform apply
```

### Plan and Apply Production Environment

```bash
cd ../prod
terraform plan
terraform apply
```

## Phase 4: Verify and Test

### Verify DNS Records

```bash
# Check web records
dig www.briananderson.xyz
dig dev-www.briananderson.xyz

# Check homelab records
dig plex.briananderson.xyz

# Check mail records
dig briananderson.xyz MX

# Check verification records
dig txt briananderson.xyz
```

### Test in Browser

```bash
# Test production
open https://www.briananderson.xyz
open https://plex.briananderson.xyz

# Test development
open https://dev-www.briananderson.xyz
open https://test-app.briananderson.xyz
```

### Run Linting

```bash
# Run Terraform format check
terraform fmt -check

# Run Terraform validate
terraform validate

# Run tflint
tflint .
```

## Phase 5: Setup GitHub Secrets

Required secrets in GitHub repository:

1. **CLOUDFLARE_API_TOKEN**: Your Cloudflare API token
2. **CLOUDFLARE_ZONE_ID**: Your Cloudflare zone ID for briananderson.xyz
3. **GOOGLE_APPLICATION_CREDENTIALS**: GCS authentication JSON (base64 encoded)

```bash
# Encode GCS credentials
base64 -i ~/.config/gcloud/application_default_credentials.json
# Copy output and add to GitHub secrets as GOOGLE_APPLICATION_CREDENTIALS
```

## Key Files Summary

| File | Purpose |
|------|---------|
| `terraform.tf` | Provider version requirements |
| `provider.tf` | Cloudflare provider configuration |
| `variables.tf` | Global input variables |
| `outputs.tf` | Global output values |
| `data.tf` | Data sources (zone lookup) |
| `main.tf` | Module orchestration |
| `modules/dns_web/` | Web DNS records module |
| `modules/dns_mail/` | Mail DNS records module |
| `modules/dns_homelab/` | Homelab DNS records module |
| `modules/dns_verification/` | Verification DNS records module |
| `environments/dev/` | Development environment config |
| `environments/prod/` | Production environment config |
| `.github/workflows/terraform.yml` | CI/CD pipeline |

## Security Considerations

1. Never commit `*.tfvars` files (they contain sensitive data)
2. Use GitHub Secrets for API tokens and credentials
3. Limit API token scopes to minimum required permissions
4. Enable versioning on GCS buckets for state rollback
5. Review PRs carefully before applying to production
6. Use separate credentials for dev and prod environments

## Next Steps

1. Update `environments/dev/terraform.tfvars` with your actual values
2. Update `environments/prod/terraform.tfvars` with your actual values
3. Create GCS buckets for state storage
4. Import existing Cloudflare records (if any)
5. Configure GitHub Secrets
6. Test CI/CD pipeline
7. Verify all DNS records are working

## Workflow Example

### Testing a New Website

```bash
# 1. Add test record to dev environment
cd environments/dev
# Update terraform.tfvars with new test-app record
terraform plan
terraform apply

# 2. Test dev-app.briananderson.xyz in browser
# Verify functionality

# 3. If works, promote to prod
cd ../prod
# Update terraform.tfvars with production record
terraform plan
terraform apply

# 4. Clean up dev record (optional)
cd ../dev
# Remove test-app from terraform.tfvars
terraform plan
terraform apply
```

### Testing Plex Updates

```bash
# 1. Create plex-dev record for testing
cd environments/dev
# Add plex-dev to terraform.tfvars
terraform apply

# 2. Test new Plex version at plex-dev.briananderson.xyz
# Verify playback, libraries, etc.

# 3. If successful, update production
cd ../prod
# Ensure plex record is correct
terraform apply

# 4. Clean up dev record
cd ../dev
# Remove plex-dev from terraform.tfvars
terraform apply
```

---

**Estimated Time:** 2-3 hours for complete setup (including importing existing records)

**Prerequisites:**
- Cloudflare account with API token
- GCS buckets created
- GitHub repository created
- Existing Cloudflare records identified
