# API kill switch and rate limiting

The `api_worker` (`api.briananderson.xyz` / `api-dev.briananderson.xyz`) protects
the billable AI endpoints (`/chat`, `/fit-finder`, `/mcp`) at the edge, before
any request reaches Cloud Run or spends Gemini tokens.

## Rate limiting

Per-IP fixed-window limiting backed by the worker's `API_STATE` KV namespace,
keyed on `cf-connecting-ip`. Defaults: **15 requests / 10 minutes** per IP
(`rate_limit` / `rate_window_seconds` module variables). Over the limit returns
`429 {"code":"rate_limited"}` with a `Retry-After` header.

Because it lives in KV, the limit is shared across every Cloud Run instance
(the in-app `express-rate-limit` is per-instance and resets on scale, so it is
only a backstop). KV is eventually consistent, so the limit is approximate:
enough to stop sustained abuse, not a hard transactional cap.

## Kill switch (`ai_enabled`)

A single KV key toggles all AI endpoints:

- key **absent** or any value other than `"false"` -> **enabled** (fail-open, so
  a missing key never dark-ships the API)
- key set to `"false"` -> AI endpoints return `503 {"code":"ai_disabled"}` at the
  edge; no Gemini spend. The frontend detects this code and shows a graceful
  "temporarily unavailable" state.

It is flipped two ways:

1. **Manually (admin)** — to take AI offline on demand:

   ```bash
   # namespace id: `terraform output api_state_kv_namespace_id` (prod)
   #               `terraform output api_state_kv_namespace_id_dev` (dev)
   wrangler kv key put ai_enabled false --namespace-id <ID>   # disable
   wrangler kv key delete ai_enabled --namespace-id <ID>      # re-enable
   ```

2. **Automatically** — the GCP billing budget breach automation sets
   `ai_enabled=false` when the monthly budget is exceeded (see the app infra
   repo). Re-enable manually with the `delete` command above once resolved.
