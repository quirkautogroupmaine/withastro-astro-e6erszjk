/*
  # Update Maine Mariners featured image

  Updates the featured image URL for the Maine Mariners hockey post to use a more appropriate hockey-related image.
*/

UPDATE posts 
SET featured_image_url = 'https://images.unsplash.com/photo-1580748141549-71748dbe0bdc?auto=format&fit=crop&w=1200&h=628'
WHERE slug = 'maine-mariners-hockey';