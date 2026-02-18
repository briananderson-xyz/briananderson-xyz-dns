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

output "tunnel_id" {
  description = "Shared tunnel UUID"
  value       = module.dns_tunnel.tunnel_id
}

output "tunnel_token" {
  description = "Tunnel token for cloudflared connector"
  value       = module.dns_tunnel.tunnel_token
  sensitive   = true
}

output "tunnel_cnames" {
  description = "Tunnel DNS records"
  value       = module.dns_tunnel.tunnel_cname_records
}

output "mcp_gateway" {
  description = "MCP Gateway details"
  value = {
    url           = module.mcp_gateway.gateway_url
    worker_name   = module.mcp_gateway.worker_name
    route_pattern = module.mcp_gateway.route_pattern
  }
}

output "service_token_credentials" {
  description = "Service token credentials for Access (CF-Access-Client-Id / CF-Access-Client-Secret)"
  value       = module.dns_tunnel.service_token_credentials
  sensitive   = true
}
