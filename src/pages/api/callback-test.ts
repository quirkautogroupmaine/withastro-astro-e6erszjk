import type { APIRoute } from 'astro';

export const GET: APIRoute = async ({ url }) => {
  const code = url.searchParams.get('code');

  if (!code) {
    return new Response(JSON.stringify({ error: 'No authorization code provided' }), {
      status: 400,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }

  return new Response(JSON.stringify({ success: true, code }), {
    status: 200,
    headers: {
      'Content-Type': 'application/json'
    }
  });
};