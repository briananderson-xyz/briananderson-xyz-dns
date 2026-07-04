output "worker_name" {
  description = "Name of the deployed Worker script"
  value       = cloudflare_workers_script.api_proxy.script_name
}

output "route_pattern" {
  description = "Worker route pattern"
  value       = cloudflare_workers_route.api.pattern
}

output "dns_record" {
  description = "API DNS record name"
  value       = cloudflare_dns_record.api.name
}

output "kv_namespace_id" {
  description = "KV namespace id backing rate limiting + the AI kill switch"
  value       = cloudflare_workers_kv_namespace.api_state.id
}
