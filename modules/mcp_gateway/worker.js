/**
 * MCP Gateway Worker
 * Routes /affine/* → affine-mcp.briananderson.xyz with CF Access headers
 * Authenticates via Bearer token
 */
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // Validate bearer token
    const authHeader = request.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return jsonError("Missing or invalid Authorization header", 401);
    }
    const token = authHeader.slice(7);
    if (token !== env.BEARER_TOKEN) {
      return jsonError("Invalid token", 403);
    }

    // Route to backend based on path prefix
    const routes = JSON.parse(env.ROUTES || "{}");
    const pathParts = url.pathname.split("/").filter(Boolean);
    const prefix = pathParts[0];

    if (!prefix || !routes[prefix]) {
      const available = Object.keys(routes);
      return jsonError(
        `Unknown route: /${prefix || ""}. Available: ${available.map((r) => "/" + r).join(", ")}`,
        404
      );
    }

    const backend = routes[prefix];
    const remainingPath = "/" + pathParts.slice(1).join("/");

    // Build upstream request
    const upstreamUrl = backend.url + remainingPath + url.search;
    const upstreamHeaders = new Headers(request.headers);

    // Remove original auth, add backend-specific headers
    upstreamHeaders.delete("Authorization");
    if (backend.headers) {
      for (const [key, value] of Object.entries(backend.headers)) {
        upstreamHeaders.set(key, value);
      }
    }
    // Set host header to upstream
    upstreamHeaders.set("Host", new URL(backend.url).host);

    const upstreamRequest = new Request(upstreamUrl, {
      method: request.method,
      headers: upstreamHeaders,
      body: request.method !== "GET" && request.method !== "HEAD" ? request.body : undefined,
    });

    return fetch(upstreamRequest);
  },
};

function jsonError(message, status) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
