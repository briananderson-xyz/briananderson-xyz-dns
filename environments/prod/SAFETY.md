# Production DNS Infrastructure

**⚠️ CRITICAL: This manages production DNS records. All changes affect live services.**

## Safety Checklist

Before running `terraform apply`, ALWAYS:

1. **Review the plan carefully**
   ```bash
   terraform plan -out=tfplan
   # Read the output completely
   terraform show tfplan
   ```

2. **Test changes in a staging context first**
   - For new records: Create temporary records with different names
   - For record modifications: Create a backup of current state
   ```bash
   terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate
   ```

3. **Verify DNS propagation**
   - Use `dig` or `nslookup` to verify changes
   - Wait for TTL to propagate before making dependent changes

4. **Monitor services**
   - Have your sites and services ready to test
   - Have rollback plan ready

## Environment Variables

All configuration is done via environment variables:

```bash
# .env file
CLOUDFLARE_API_TOKEN=xxx                    # Cloudflare provider auth (auto-detected)
TF_VAR_cloudflare_zone_id=xxx              # Cloudflare zone ID
TF_VAR_dkim_public_key=xxx                 # Gmail DKIM public key
TF_VAR_google_site_verification=xxx          # Google site verification (optional)
```

**Load and use:**
```bash
# Load .env file
set -a
source .env
set -a

# Run Terraform
terraform init
terraform plan
terraform apply
```

## GitHub Actions

CI/CD uses these secrets:
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ZONE_ID`
- `DKIM_PUBLIC_KEY`
- `GOOGLE_SITE_VERIFICATION` (optional)

## Current State

- **15 DNS records** deployed to Cloudflare
- **Zone:** briananderson.xyz (your_zone_id_here)
- **State:** gs://your-terraform-state-bucket/dns/prod/
- **Last applied:** 2026-01-22

## Records Managed

| Type | Count | Purpose |
|------|-------|---------|
| Web (A/CNAME) | 7 | admin, auth, domainconnect, fairview, home, root (@), www |
| Mail (MX) | 5 | Gmail servers |
| SPF (TXT) | 1 | `v=spf1 include:_spf.google.com ~all` |
| DKIM (TXT) | 1 | Gmail DKIM signature |
| Verification (TXT) | 1 | Google site verification |

## Emergency Rollback

If something goes wrong:

```bash
# Restore from backup state
terraform state push backup-YYYYMMDD-HHMMSS.tfstate

# Or manually recreate deleted records in Cloudflare dashboard
# Then run: terraform import
```

## Testing Changes

For testing DNS changes safely:

1. **Use test subdomains** (e.g., `test-admin.briananderson.xyz`)
2. **Monitor DNS propagation**: `dig test-admin.briananderson.xyz`
3. **Test application** before switching to production names
4. **Keep old records** until new ones are verified working
