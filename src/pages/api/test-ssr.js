export async function GET() {
  return new Response(JSON.stringify({ message: "SSR is working!" }), {
    headers: { "Content-Type": "application/json" },
  });
}
