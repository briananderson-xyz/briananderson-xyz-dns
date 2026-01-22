output "record_names" {
  description = "List of all web DNS record names"
  value       = [for record in cloudflare_record.web : record.name]
}

output "record_ids" {
  description = "List of all web DNS record IDs"
  value       = [for record in cloudflare_record.web : record.id]
}
