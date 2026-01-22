output "record_names" {
  description = "List of all mail DNS record names"
  value = concat(
    [for record in cloudflare_record.mx : record.name],
    var.mail_records.spf != null ? [cloudflare_record.spf["spf"].name] : [],
    var.mail_records.dkim != null ? [cloudflare_record.dkim["dkim"].name] : [],
    var.mail_records.dmarc != null ? [cloudflare_record.dmarc["dmarc"].name] : []
  )
}
