import { supabase } from './supabase';

async function getQuirkLocations() {
  const { data: locations, error } = await supabase
    .from('quirk_locations')
    .select('*')
    .order('title');

  if (error) throw error;
  return locations;
}

async function getQuirkLocationBySlug(slug: string) {
  const { data: location, error } = await supabase
    .from('quirk_locations')
    .select(`
      *,
      posts(
        id,
        title,
        slug,
        excerpt,
        featured_image_url,
        published_at,
        categories:post_categories(category:categories(name))
      )
    `)
    .eq('slug', slug)
    .single();

  if (error) throw error;
  return location;
}

export async function createQuirkLocation(data: {
  title: string;
  location_logo?: string;
  location_featured_image?: string;
  youtube_profile?: string;
  physical_address: string;
  city: string;
  state: string;
  zip_code: string;
  website?: string;
  facebook?: string;
  instagram?: string;
  gmb?: string;
  content_description?: string;
}) {
  const { error } = await supabase
    .from('quirk_locations')
    .insert([{
      ...data,
      slug: data.title.toLowerCase().replace(/[^a-z0-9]+/g, '-')
    }]);

  if (error) throw error;
}

export async function updateQuirkLocation(
  id: string,
  data: Partial<{
    title: string;
    location_logo: string;
    location_featured_image: string;
    youtube_profile: string;
    physical_address: string;
    city: string;
    state: string;
    zip_code: string;
    website: string;
    facebook: string;
    instagram: string;
    gmb: string;
    content_description: string;
  }>
) {
  const { error } = await supabase
    .from('quirk_locations')
    .update(data)
    .eq('id', id);

  if (error) throw error;
}