// Image optimization configuration
const CLOUDFLARE_ACCOUNT_ID = '30674f493465e4c909165b0acf456988';
const CLOUDFLARE_IMAGE_DELIVERY = `https://imagedelivery.net/${CLOUDFLARE_ACCOUNT_ID}`;

type ImageOptions = {
  width?: number;
  height?: number;
  quality?: number;
  format?: 'auto' | 'webp' | 'avif';
  fit?: 'cover' | 'contain' | 'fill';
};

export function getOptimizedImageUrl(
  imageUrl: string,
  variant: string,
  options: ImageOptions = {}
): string {
  // For external URLs (like Unsplash), use Cloudflare Image Resizing
  if (imageUrl.startsWith('http')) {
    const url = new URL(imageUrl);
    
    if (options.width) url.searchParams.set('width', options.width.toString());
    if (options.height) url.searchParams.set('height', options.height.toString());
    if (options.quality) url.searchParams.set('quality', options.quality.toString());
    if (options.format) url.searchParams.set('format', options.format);
    if (options.fit) url.searchParams.set('fit', options.fit);
    
    return url.toString();
  }

  // For uploaded images, use Cloudflare Images
  const params = new URLSearchParams();
  
  if (options.width) params.set('width', options.width.toString());
  if (options.height) params.set('height', options.height.toString());
  if (options.quality) params.set('quality', options.quality.toString());
  if (options.format) params.set('format', options.format);
  if (options.fit) params.set('fit', options.fit);

  return `${CLOUDFLARE_IMAGE_DELIVERY}/${imageUrl}/${variant}?${params.toString()}`;
}

// Helper function to get srcset for responsive images
export function getSrcSet(
  imageUrl: string,
  sizes: number[],
  options: Omit<ImageOptions, 'width'> = {}
): string {
  return sizes
    .map(width => {
      const url = getOptimizedImageUrl(imageUrl, 'responsive', {
        ...options,
        width
      });
      return `${url} ${width}w`;
    })
    .join(', ');
}