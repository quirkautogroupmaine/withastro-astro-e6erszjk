import type { APIRoute } from 'astro';
import { supabase } from '../../lib/supabase';

export const GET: APIRoute = async ({ url }) => {
  const type = url.searchParams.get('type') as 'sponsorship' | 'donation' | 'news';
  const start = Number(url.searchParams.get('start')) || 0;
  const end = Number(url.searchParams.get('end')) || 5;

  try {
    let query = supabase
      .from('posts')
      .select(`
        id,
        title,
        slug,
        excerpt,
        featured_image_url,
        published_at,
        quirk_location:quirk_locations(title),
        categories:post_categories!inner(
          category:categories!inner(name, slug)
        )
      `)
      .eq('published', true)
      .order('published_at', { ascending: false })
      .range(start, end);

    // Add type filter if specified
    if (type === 'sponsorship' || type === 'donation' || type === 'news') {
      query = query.eq('post_categories.category.slug', type);
    }

    const { data: posts, error } = await query;

    if (error) throw error;

    return new Response(JSON.stringify({ posts }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'public, max-age=60',
      },
    });

  } catch (error) {
    console.error('API Error:', error);
    return new Response(JSON.stringify({ error: 'Failed to fetch posts' }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      },
    });
  }
};