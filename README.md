# briananderson-xyz-dns

Modular Terraform project to manage all DNS records for `briananderson.xyz` via Cloudflare.

## 🎯 What This Project Shows Off

This is a **production-grade** Terraform setup demonstrating:
- ✅ Modular DNS record management
- ✅ Environment separation (dev/prod)
- ✅ Cloudflare provider integration
- ✅ CI/CD automation with GitHub Actions
- ✅ Secure secret management
- ✅ Terraform best practices (validation, modules)

Perfect for developer portfolios and infrastructure automation showcases!

---

## 📁 Project Structure

```
briananderson-xyz-dns/
├── modules/
│   ├── dns_web/          # Web DNS records (A, CNAME)
│   ├── dns_mail/         # Mail DNS records (MX, DKIM)
│   ├── dns_homelab/      # Homelab services (Plex, NAS)
│   └── dns_verification/ # Domain verification (TXT)
├── environments/
│   ├── dev/             # Development environment
│   │   ├── backend.tf   # GCS state bucket (dev)
│   │   └── terraform.tfvars  # Dev DNS records
│   └── prod/            # Production environment
│       ├── backend.tf   # GCS state bucket (prod)
│       └── terraform.tfvars  # Prod DNS records
├── .github/workflows/
│   └── terraform.yml    # CI/CD pipeline
├── main.tf                    # Root module orchestration
├── variables.tf               # Global variables
├── outputs.tf                # Global outputs
├── data.tf                   # Data sources
└── provider.tf               # Cloudflare provider
```

---

## 🚀 Quick Start

### 1. Install Prerequisites

```bash
# Terraform (>= 1.5.0)
wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify
terraform --version

# cf-terraforming (for importing existing records)
wget https://github.com/cloudflare/cf-terraforming/releases/download/v0.11.0/cf-terraforming_0.11.0_linux_amd64.tar.gz
tar -xzf cf-terraforming_0.11.0_linux_amd64.tar.gz
sudo mv cf-terraforming /usr/local/bin/
```

### 2. Create GCS Buckets (State Storage)

```bash
gsutil mb -l us-central1 gs://terraform-state-dev
gsutil versioning set on gs://terraform-state-dev

gsutil mb -l us-central1 gs://terraform-state-prod
gsutil versioning set on gs://terraform-state-prod
```

### 3. Setup Authentication (Choose One)

**Option A: OIDC (Recommended) - Modern, Secure, Organization-Level**

Run the OIDC setup script:
```bash
./setup_oidc.sh
# Choose "org" level for organization-wide setup
```

Only 2 GitHub secrets needed:
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ZONE_ID`

**No GCP secrets required!** ✅

See: [ORGANIZATION_OIDC.md](ORGANIZATION_OIDC.md) and [OIDC_SETUP.md](OIDC_SETUP.md)

---

**Option B: Service Account Key (Legacy) - Simple Setup**

Run the secrets setup script:
```bash
./setup_github_secrets.sh
```

Requires 3 GitHub secrets:
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ZONE_ID`
- `GOOGLE_APPLICATION_CREDENTIALS` (base64-encoded)

See: [SECRETS.md](SECRETS.md)

### 4. Initialize Terraform

**Development Environment:**
```bash
cd environments/dev
terraform init
```

**Production Environment:**
```bash
cd environments/prod
terraform init
```

### 5. Apply Configuration

```bash
terraform plan
terraform apply
```

---

## 🔐 Security

### Secret Management
- ✅ No secrets in git repository
- ✅ All sensitive data in GitHub Secrets
- ✅ Separate `.tfvars.local` files for local development
- ✅ Sensitive values masked in example files

### See: [SECRETS.md](SECRETS.md) for details

### Portfolio Security
- ✅ Public configuration (demonstrates skills)
- ✅ No actual secrets in code (uses placeholders)
- ✅ Sensitive items masked in examples
- ✅ Perfect for public portfolio/interviews

### See: [PORTFOLIO_SECURITY.md](PORTFOLIO_SECURITY.md) for analysis

---

## 📊 Architecture

### Environments

| Environment | Purpose | Records Managed | State Storage |
|-------------|----------|---------------|---------------|
| **dev** | Web application testing | dev-www, test-app, staging | gs://terraform-state-dev |
| **prod** | Production services | Web, Mail, Homelab, Verification | gs://terraform-state-prod |

### Modules

| Module | Record Types | Example Records |
|--------|---------------|------------------|
| **dns_web** | A, CNAME | www, admin, fairview, auth |
| **dns_mail** | MX, TXT (DKIM, SPF, DMARC) | Gmail servers, email authentication |
| **dns_homelab** | A, AAAA | Plex, NAS, VPN |
| **dns_verification** | TXT | Google site verification |

---

## 🔄 CI/CD Pipeline

GitHub Actions workflow automatically:

**On Pull Request:**
- Checkout code
- Setup Terraform
- Run `terraform fmt -check`
- Run `terraform validate`
- Run `terraform plan`
- Comment plan on PR

**On Push to main:**
- All validation steps above
- Run `terraform apply` (automatic deployment)

### Secrets Required
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token
- `CLOUDFLARE_ZONE_ID` - Zone ID for briananderson.xyz
- `GOOGLE_APPLICATION_CREDENTIALS` - Base64-encoded GCS credentials

---

## 📝 Current Configuration

### Production Records
- **Web**: 7 records (admin, fairview, auth, root, www, domainconnect, home)
- **Mail**: 6 records (5x MX + 1x DKIM)
- **Homelab**: Ready for Plex
- **Verification**: 1 record (Google site verification)

### See: [DNS_IMPORT_SUMMARY.md](DNS_IMPORT_SUMMARY.md) for details

---

## 🛠️ Usage Examples

### Add New Web Record

```bash
# Edit environments/prod/terraform.tfvars
vim environments/prod/terraform.tfvars

# Add new record
web_records = {
  "new-app" = {
    name    = "new-app"
    type    = "A"
    value   = "192.0.2.100"
    proxied = true
    ttl     = 1
  },
  # ... existing records
}

# Apply changes
cd environments/prod
terraform plan
terraform apply
```

### Add Plex to Homelab

```bash
# Edit environments/prod/terraform.tfvars
vim environments/prod/terraform.tfvars

# Add homelab configuration
homelab_public_ip = "YOUR_PUBLIC_IP"
homelab_services = {
  "plex" = {
    name    = "plex"
    proxied = true
    ttl     = 1
    comment = "Plex media server"
  }
}

# Apply changes
cd environments/prod
terraform plan
terraform apply
```

### Test in Dev Environment First

```bash
# Add dev record
cd environments/dev
vim terraform.tfvars

# Add test record
web_records = {
  "test-new-feature" = {
    name    = "test-new-feature"
    type    = "CNAME"
    value   = "c.storage.googleapis.com"
    proxied = true
    ttl     = 300  # Fast TTL for testing
  }
}

# Apply and test
terraform plan
terraform apply

# Once verified, promote to prod
cd ../prod
vim terraform.tfvars
# Add production version
terraform plan
terraform apply
```

---

## 📚 Documentation

| File | Purpose |
|-------|---------|
| [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) | Complete implementation guide |
| [DNS_IMPORT_SUMMARY.md](DNS_IMPORT_SUMMARY.md) | Imported DNS records summary |
| [existing_records_analysis.md](existing_records_analysis.md) | Detailed records analysis |
| [SECRETS.md](SECRETS.md) | Secret management guide |
| [PORTFOLIO_SECURITY.md](PORTFOLIO_SECURITY.md) | Portfolio security analysis |

---

## 🧪 Testing

### Validate DNS Records

```bash
# Web records
dig www.briananderson.xyz
dig admin.briananderson.xyz

# Mail records
dig briananderson.xyz MX

# Verification records
dig txt briananderson.xyz
```

### Run Terraform Validation

```bash
# Format check
terraform fmt -check

# Syntax validation
terraform validate

# Linting
tflint .
```

---

## 🤝 Contributing

This is a personal project for portfolio demonstration, but feel free to:
- Fork and customize for your domain
- Submit issues or PRs for improvements
- Use as reference for your own DNS management

---

## 📄 License

MIT License - Use and modify freely for your own projects.

---

## 🎓 What This Demonstrates

Perfect for interviews and portfolios - shows you understand:

1. **Terraform Modules** - Reusable, maintainable code
2. **DNS Management** - A, CNAME, MX, DKIM, DMARC records
3. **Cloudflare Provider** - Modern DNS provider integration
4. **State Management** - GCS backend with versioning
5. **Environment Separation** - Dev/prod isolation strategy
6. **CI/CD Automation** - GitHub Actions workflows
7. **Security Best Practices** - Secret management, no hardcoding
8. **Infrastructure as Code** - Declarative, versioned, reproducible

---

## 🚀 Ready to Showcase?

1. ✅ Review code - All files use placeholders (no secrets!)
2. ✅ Run `./setup_github_secrets.sh` - Get GitHub secrets values
3. ✅ Add GitHub Secrets - Configure CI/CD pipeline
4. ✅ Commit and push - Initialize git and push to GitHub
5. ✅ Pin to profile - Show off your automation skills!

**Your public portfolio demonstrating real infrastructure automation!** 🎉
