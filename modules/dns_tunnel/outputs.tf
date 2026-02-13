output "tunnel_ids" {
  value = { for k, v in cloudflare_tunnel.tunnel : k => v.id }
}

output "tunnel_credentials" {
  value     = { for k, v in cloudflare_tunnel.tunnel : k => { id = v.id, secret = v.secret } }
  sensitive = true
}
