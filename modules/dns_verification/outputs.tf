output "record_names" {
  description = "List of all verification DNS record names"
  value       = [for record in cloudflare_dns_record.verification : record.name]
}
