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

    // /chat and /fit-finder forward to a Cloud Run service root. The MCP
    // server lives on the chat service at the /mcp path (CHAT_URL is a base
    // URL with no path), so /mcp forwards there specifically.
    const chatBase = env.CHAT_URL.replace(/\/$/, "");
    const routes = {
      "/chat": env.CHAT_URL,
      "/fit-finder": env.FIT_FINDER_URL,
      "/mcp": `${chatBase}/mcp`,
    };

    const target = routes[url.pathname];
    if (!target) {
      return new Response(JSON.stringify({ error: "Not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    // Forward Content-Type, plus Accept for the MCP Streamable HTTP transport,
    // which requires the client's Accept header (application/json,
    // text/event-stream) to reach the origin. Harmless for the other routes.
    const forwardHeaders = {
      "Content-Type": request.headers.get("Content-Type") || "application/json",
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
