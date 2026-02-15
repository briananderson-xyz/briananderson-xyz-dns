output "gateway_url" {
  description = "MCP Gateway URL"
  value       = "https://${var.hostname}.${var.domain}"
}

output "worker_name" {
  description = "Worker script name"
  value       = cloudflare_workers_script.mcp_gateway.script_name
}

output "route_pattern" {
  description = "Workers route pattern"
  value       = cloudflare_workers_route.mcp_gateway.pattern
}
