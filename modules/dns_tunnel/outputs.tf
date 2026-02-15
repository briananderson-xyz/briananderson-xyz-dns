output "tunnel_ids" {
  description = "Map of service key to tunnel UUID"
  value       = { for k, v in cloudflare_zero_trust_tunnel_cloudflared.tunnel : k => v.id }
}

output "tunnel_secrets" {
  description = "Tunnel secrets (retrieve install token from Zero Trust dashboard → Networks → Tunnels → Install connector)"
  value       = { for k, v in cloudflare_zero_trust_tunnel_cloudflared.tunnel : k => { id = v.id, status = v.status } }
}

output "service_token_credentials" {
  description = "Service token credentials for machine auth (CF-Access-Client-Id / CF-Access-Client-Secret headers)"
  value = {
    for k, v in cloudflare_zero_trust_access_service_token.token : k => {
      client_id     = v.client_id
      client_secret = v.client_secret
    }
  }
  sensitive = true
}

output "tunnel_cname_records" {
  description = "DNS CNAME records created for tunnels"
  value       = { for k, v in cloudflare_dns_record.tunnel_cname : k => v.name }
}
