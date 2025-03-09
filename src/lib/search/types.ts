type ContentType = 'iyc' | 'job' | 'post';

export interface SearchResult {
  id: string;
  type: ContentType;
  title: string;
  description: string;
  featured_image_url?: string;
  url: string;
  quirk_location?: {
    id: string;
    title: string;
    city?: string;
  };
  additional_data?: {
    slug?: string;
    excerpt?: string;
    department?: string;
    employment_type?: string;
    published_at?: string;
    [key: string]: any;
  };
}