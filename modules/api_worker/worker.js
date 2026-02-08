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

    const routes = {
      "/chat": env.CHAT_URL,
      "/fit-finder": env.FIT_FINDER_URL,
    };

    const target = routes[url.pathname];
    if (!target) {
      return new Response(JSON.stringify({ error: "Not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    // Forward request to Cloud Run
    const response = await fetch(target, {
      method: request.method,
      headers: { "Content-Type": request.headers.get("Content-Type") || "application/json" },
      body: request.method !== "GET" ? request.body : undefined,
    });

    // Return response with CORS headers
    const newResponse = new Response(response.body, response);
    newResponse.headers.set("Access-Control-Allow-Origin", allowOrigin);
    return newResponse;
  },
};
