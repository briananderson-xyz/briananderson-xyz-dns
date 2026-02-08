# Production Environment

This environment manages production DNS records for websites, homelab services, mail, and verification.

## Records Managed

### Web
- **@**: Main domain (briananderson.xyz)
- **www**: Production website
- **blog**: Production blog

### Homelab
- **plex**: Plex media server

### Mail (Gmail)
- **MX Records**: Gmail mail servers
- **SPF**: Email spam prevention
- **DKIM**: Email authentication
- **DMARC**: Email policy

### Verification
- **google-site-verification**: Google domain ownership

## Characteristics

- **TTL**: 3600s (1 hour) for stability
- **Purpose**: Production services with stable configuration
- **State**: Stored in `gs://terraform-state-prod/briananderson-xyz-dns`

## Workflow

1. Test changes in development environment first
2. Once verified, update corresponding prod record in `terraform.tfvars`
3. Run `terraform plan` to preview changes
4. Run `terraform apply` to apply changes
5. Verify production records are working correctly
