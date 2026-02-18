output "tunnel_id" {
  description = "Shared tunnel UUID"
  value       = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
}

output "tunnel_token" {
  description = "Tunnel token for cloudflared connector (run: cloudflared tunnel run --token <token>)"
  value = base64encode(jsonencode({
    a = var.account_id
    t = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
    s = base64encode(random_bytes.tunnel_secret.hex)
  }))
  sensitive = true
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
