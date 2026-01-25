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
├── .env                      # Local secrets (gitignored) ⚠️
├── .gitignore
├── .github/workflows/          # GitHub Actions CI/CD
│   └── terraform.yml
├── modules/
│   ├── dns_web/             # Web DNS records (A, CNAME)
│   ├── dns_mail/            # Mail DNS records (MX, DKIM, SPF)
│   ├── dns_homelab/         # Homelab services (Plex, NAS)
│   └── dns_verification/     # Domain verification (TXT)
├── environments/
│   └── prod/               # Production environment (only env)
│       ├── backend.tf        # GCS state storage
│       ├── provider.tf      # Cloudflare provider
│       ├── terraform.tf     # Provider requirements
│       ├── terraform.tfvars # DNS record config (committed)
│       ├── main.tf         # Module instantiations
│       ├── variables.tf     # Variable definitions
│       ├── SAFETY.md       # ⚠️ Safety checklist (READ THIS)
│       └── README.md
└── modules/ (reusable components)
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

See: [SECRETS.md](SECRETS.md)

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

### 4. Create .env File (Local Development)

```bash
# Create .env in repo root (gitignored)
cat > .env << 'EOF'
# Cloudflare Provider Authentication (auto-detected)
CLOUDFLARE_API_TOKEN=your_api_token_here

# Terraform Variables (use TF_VAR_ prefix)
TF_VAR_cloudflare_zone_id=your_zone_id_here
TF_VAR_dkim_public_key=your_dkim_key_here
TF_VAR_google_site_verification=optional_verification_token
EOF
```

### 5. Initialize Terraform

```bash
cd environments/prod
terraform init
```

### 6. Apply Configuration

```bash
# Load environment variables and apply
set -a
source ../../.env
set -a

terraform plan
terraform apply
```

---

## 🔐 Security

### Secret Management
- ✅ No secrets in git repository (.env is gitignored)
- ✅ All secrets via environment variables
- ✅ CLOUDFLARE_API_TOKEN auto-detected by provider
- ✅ Custom variables use TF_VAR_ prefix (Terraform standard)
- ✅ Sensitive values masked in example files

### See: [SECRETS.md](SECRETS.md) for details

### Portfolio Security
- ✅ Public configuration (demonstrates skills)
- ✅ No actual secrets in code (uses placeholders)
- ✅ Sensitive items masked in examples
- ✅ Perfect for public portfolio/interviews

### See: [PORTFOLIO_SECURITY.md](PORTFOLIO_SECURITY.md) for analysis

### ⚠️ IMPORTANT: Read SAFETY.md
Before making changes, review `environments/prod/SAFETY.md` - this manages production DNS!

---

## 📊 Architecture

### Environments

| Environment | Purpose | Records Managed | State Storage |
|-------------|----------|---------------|---------------|
| **prod** | Production services | 15 DNS records (Web, Mail, Verification) | gs://briananderson-xyz-tf-state/dns/prod/ |

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
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token (auto-detected)
- `TF_VAR_cloudflare_zone_id` - Zone ID for briananderson.xyz
- `TF_VAR_dkim_public_key` - Gmail DKIM public key
- `TF_VAR_google_site_verification` - Google site verification (optional)

**Note**: GitHub Actions uses GCS OIDC for backend authentication (no `GOOGLE_APPLICATION_CREDENTIALS` needed)

---

## 📝 Current Configuration

### Production Records
- **Web**: 7 records (admin, fairview, auth, root, www, domainconnect, home)
- **Mail**: 7 records (5x MX + 1x SPF + 1x DKIM)
- **Verification**: 1 record (Google site verification)
- **Total**: 15 DNS records

### Email Authentication
- ✅ SPF: `v=spf1 include:_spf.google.com ~all`
- ✅ DKIM: Configured with Gmail public key
- ✅ MX: 5 Gmail servers configured

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
set -a && source ../../.env && set -a
terraform plan -out=tfplan
terraform apply tfplan
```

### Test Changes Safely

**Always test before affecting production:**

```bash
# Create test record with different name
cd environments/prod
vim terraform.tfvars

# Add test record
web_records = {
  "test-admin" = {
    name    = "test-admin"
    type    = "A"
    value   = "192.0.2.1"
    proxied = true
    ttl     = 1
  },
  # ... existing records
}

# Apply and verify
set -a && source ../../.env && set -a
terraform plan -out=tfplan
terraform apply tfplan

# Verify DNS propagation
dig test-admin.briananderson.xyz

# Test your application with test-admin.briananderson.xyz

# Remove test record once verified
# Revert terraform.tfvars change and apply
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

# Email authentication
dig txt google._domainkey.briananderson.xyz  # DKIM
dig txt briananderson.xyz                      # SPF
```

### Run Terraform Validation

```bash
cd environments/prod

# Format check
terraform fmt -check

# Syntax validation
terraform validate
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
2. ✅ Create .env file - Add your Cloudflare credentials
3. ✅ Add GitHub Secrets - Configure CI/CD pipeline
4. ✅ Commit and push - Push to GitHub (`.env` is gitignored)
5. ✅ Pin to profile - Show off your automation skills!

**Your public portfolio demonstrating real infrastructure automation!** 🎉

⚠️ **IMPORTANT**: Read `environments/prod/SAFETY.md` before making any changes!
