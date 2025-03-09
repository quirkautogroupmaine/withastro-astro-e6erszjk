-- Add sample It's Your Car posts
INSERT INTO posts (
  title,
  slug,
  featured_image_url,
  excerpt,
  content,
  quirk_location_id,
  published,
  published_at,
  post_rank,
  is_sticky
) VALUES
  (
    'It''s Your Car: 2024 Chevrolet Silverado - The Perfect Match for the Smith Family',
    'its-your-car-2024-chevrolet-silverado-smith-family',
    'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&h=628',
    'Congratulations to the Smith family on their new 2024 Chevrolet Silverado! The perfect truck for their outdoor adventures and family activities.',
    '<p>We''re thrilled to celebrate with the Smith family as they drive home in their brand new 2024 Chevrolet Silverado! After searching for the perfect vehicle to accommodate their active lifestyle, the Silverado''s combination of power, comfort, and versatility made it the ideal choice.</p>
    
    <p>The Smith family was particularly impressed with the Silverado''s spacious interior, advanced safety features, and impressive towing capacity - perfect for their camping trips and boat adventures!</p>
    
    <p>Thank you for choosing Quirk Chevrolet Bangor for your automotive needs. We''re honored to be part of your car-buying journey!</p>',
    (SELECT id FROM quirk_locations WHERE title ILIKE '%Chevrolet%Bangor%' LIMIT 1),
    true,
    NOW() - interval '2 days',
    1,
    true
  ),
  (
    'It''s Your Car: Sarah''s First Subaru - A Perfect Match',
    'its-your-car-sarahs-first-subaru',
    'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&h=628',
    'Celebrating with Sarah as she drives home in her first Subaru! A perfect match for her adventurous spirit and Maine lifestyle.',
    '<p>Today we''re celebrating with Sarah as she begins her Subaru journey! As a first-time Subaru owner, Sarah was drawn to the Crosstrek''s reputation for reliability, safety, and all-weather capability.</p>
    
    <p>Sarah''s new Crosstrek is equipped with Symmetrical All-Wheel Drive and EyeSight® Driver Assist Technology, making it perfect for her daily commute and weekend hiking adventures.</p>
    
    <p>Welcome to the Subaru family, Sarah! We know you''ll love every minute of the Subaru experience.</p>',
    (SELECT id FROM quirk_locations WHERE title ILIKE '%Subaru%' LIMIT 1),
    true,
    NOW() - interval '3 days',
    2,
    false
  ),
  (
    'It''s Your Car: The Johnson Family''s New Jeep Grand Cherokee',
    'its-your-car-johnson-family-jeep-grand-cherokee',
    'https://images.unsplash.com/photo-1533591362725-979dfce672b5?auto=format&fit=crop&w=1200&h=628',
    'Congratulations to the Johnson family on their new Jeep Grand Cherokee! The perfect blend of luxury and capability for their growing family.',
    '<p>We''re excited to share in the Johnson family''s joy as they drive home in their new Jeep Grand Cherokee! After comparing various SUVs, the Grand Cherokee''s combination of luxury, safety features, and off-road capability made it the clear winner.</p>
    
    <p>The Johnsons particularly loved the premium interior, advanced technology features, and the confidence that comes with Jeep''s legendary 4x4 capability.</p>
    
    <p>Thank you for choosing Quirk CDJR Bangor! We''re looking forward to serving your family for years to come.</p>',
    (SELECT id FROM quirk_locations WHERE title ILIKE '%CDJR%Bangor%' LIMIT 1),
    true,
    NOW() - interval '4 days',
    3,
    false
  );

-- Add category associations
WITH new_posts AS (
  SELECT id FROM posts 
  WHERE slug IN (
    'its-your-car-2024-chevrolet-silverado-smith-family',
    'its-your-car-sarahs-first-subaru',
    'its-your-car-johnson-family-jeep-grand-cherokee'
  )
)
INSERT INTO post_categories (post_id, category_id)
SELECT new_posts.id, categories.id
FROM new_posts
CROSS JOIN categories
WHERE categories.slug = 'its-your-car';