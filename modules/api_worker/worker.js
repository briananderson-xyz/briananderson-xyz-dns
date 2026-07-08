// API edge proxy for api.briananderson.xyz.
//
// Proxies /chat, /fit-finder, and /mcp to their Cloud Run services, and adds
// two edge protections in front of those (all-Gemini, all-billable) endpoints:
//
//   1. Kill switch — a KV key `ai_enabled`. When set to "false" (manually by
//      an admin, or automatically when the GCP budget is exceeded), the AI
//      endpoints return 503 {code:"ai_disabled"} before reaching Cloud Run, so
//      no Gemini spend occurs. Absent/any-other-value means enabled (fail-open
//      so a missing key never dark-ships the API).
//   2. Per-IP rate limiting — a fixed-window counter in KV keyed on
//      cf-connecting-ip. Shared across all Cloud Run instances (unlike the
//      in-app limiter), so it actually bounds abuse. Approximate (KV is
//      eventually consistent), which is fine for stopping sustained abuse.
//
// Both are backed by the API_STATE KV binding; if it is somehow absent the
// worker still proxies (fails open on protection, never on availability).

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    const ALLOWED_ORIGINS = [
      "https://briananderson.xyz",
      "https://www.briananderson.xyz",
      "https://dev.briananderson.xyz",
    ];

    const origin = request.headers.get("Origin");
    const allowOrigin = ALLOWED_ORIGINS.includes(origin)
      ? origin
      : ALLOWED_ORIGINS[0];

    const corsHeaders = {
      "Access-Control-Allow-Origin": allowOrigin,
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Max-Age": "86400",
    };

    // CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    // /chat and /fit-finder forward to a Cloud Run service root. The MCP server
    // lives on the chat service at the /mcp path (CHAT_URL is a base URL).
    const chatBase = env.CHAT_URL.replace(/\/$/, "");
    const routes = {
      "/chat": env.CHAT_URL,
      "/fit-finder": env.FIT_FINDER_URL,
      "/mcp": chatBase + "/mcp",
    };

    const target = routes[url.pathname];
    if (!target) {
      return jsonError("Not found", 404, corsHeaders);
    }

    // Edge protections (kill switch + rate limit). Backed by KV; if the binding
    // is missing we fail open so availability never depends on it.
    if (env.API_STATE) {
      const enabled = await env.API_STATE.get("ai_enabled");
      if (enabled === "false") {
        return jsonError(
          "AI features are temporarily unavailable. Please try again later.",
          503,
          corsHeaders,
          "ai_disabled"
        );
      }

      const limit = Number(env.RATE_LIMIT || "15");
      const windowSeconds = Number(env.RATE_WINDOW_SECONDS || "600");
      const ip = request.headers.get("cf-connecting-ip") || "unknown";
      const bucket = Math.floor(Date.now() / (windowSeconds * 1000));
      const rateKey = "rl:" + ip + ":" + bucket;

      const current = Number((await env.API_STATE.get(rateKey)) || "0");
      if (current >= limit) {
        return jsonError(
          "Rate limit exceeded. Please slow down and try again shortly.",
          429,
          corsHeaders,
          "rate_limited",
          windowSeconds
        );
      }
      // Best-effort increment. KV is eventually consistent, so this is an
      // approximate limiter — good enough to stop sustained abuse. TTL expires
      // the counter at the end of the window.
      await env.API_STATE.put(rateKey, String(current + 1), {
        expirationTtl: windowSeconds,
      });
    }

    // Forward Content-Type, plus Accept for the MCP Streamable HTTP transport,
    // which requires the client's Accept header to reach the origin. Harmless
    // for /chat and /fit-finder.
    const forwardHeaders = {
      "Content-Type": request.headers.get("Content-Type") || "application/json",
      "X-Origin-Verify": env.ORIGIN_VERIFY_TOKEN,
    };
    const accept = request.headers.get("Accept");
    if (accept) forwardHeaders["Accept"] = accept;

    // Forward request to the Cloud Run target
    const response = await fetch(target, {
      method: request.method,
      headers: forwardHeaders,
      body: request.method !== "GET" ? request.body : undefined,
    });

    // Return response with CORS headers
    const newResponse = new Response(response.body, response);
    newResponse.headers.set("Access-Control-Allow-Origin", allowOrigin);
    return newResponse;
  },
};

function jsonError(message, status, corsHeaders, code, retryAfterSeconds) {
  const headers = { "Content-Type": "application/json", ...corsHeaders };
  if (retryAfterSeconds) headers["Retry-After"] = String(retryAfterSeconds);
  const body = { error: message };
  if (code) body.code = code;
  return new Response(JSON.stringify(body), { status, headers });
}
