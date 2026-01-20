# Development Environment

This environment manages development and testing DNS records for web applications.

## Records Managed

- **dev-www**: Development website (staging server)
- **test-app**: Test application environment
- **staging**: Pre-production staging environment

## Characteristics

- **TTL**: 300s (5 minutes) for fast iteration
- **Purpose**: Safe testing of web changes before production
- **State**: Stored in `gs://terraform-state-dev/briananderson-xyz-dns`

## Workflow

1. Add or modify records in `terraform.tfvars`
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes
4. Test dev subdomain (e.g., `dev-www.briananderson.xyz`)
5. Once verified, promote to production environment
