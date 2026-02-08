output "record_names" {
  description = "List of all homelab DNS record names"
  value       = [for record in cloudflare_dns_record.homelab : record.name]
}
