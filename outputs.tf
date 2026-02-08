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

output "api_worker" {
  description = "API Worker details"
  value = {
    worker_name   = module.api_worker.worker_name
    route_pattern = module.api_worker.route_pattern
    dns_record    = module.api_worker.dns_record
  }
}
