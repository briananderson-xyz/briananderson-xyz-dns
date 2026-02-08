output "web_records" {
  description = "All web DNS record names"
  value       = module.dns_web.record_names
}

output "mail_records" {
  description = "All mail DNS record names"
  value       = module.dns_mail.record_names
}

output "homelab_records" {
  description = "All homelab DNS record names"
  value       = module.dns_homelab.record_names
}

output "verification_records" {
  description = "All verification DNS record names"
  value       = module.dns_verification.record_names
}
