output "tunnel_ids" {
  value = { for k, v in cloudflare_zero_trust_tunnel_cloudflared.tunnel : k => v.id }
}

output "tunnel_credentials" {
  value     = { for k, v in cloudflare_zero_trust_tunnel_cloudflared.tunnel : k => { id = v.id, secret = v.secret } }
  sensitive = true
}
