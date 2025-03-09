/*
  # Update post images to 1200x628

  Updates all post featured images to use properly sized 1200x628 images from Unsplash.

  1. Changes
    - Updates featured_image_url for all existing posts
*/

UPDATE posts 
SET featured_image_url = CASE 
  WHEN slug = 'umaine-black-bear-athletics' 
    THEN 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&h=628'
  WHEN slug = 'maine-mariners-hockey'
    THEN 'https://images.unsplash.com/photo-1515703407324-5f73fb9696b4?auto=format&fit=crop&w=1200&h=628'
  WHEN slug = 'maine-veterans-project-support'
    THEN 'https://images.unsplash.com/photo-1523540939399-141cbff6a8d7?auto=format&fit=crop&w=1200&h=628'
  WHEN slug = 'project-linus-comfort-through-blankets'
    THEN 'https://images.unsplash.com/photo-1445991842772-097fea258e7b?auto=format&fit=crop&w=1200&h=628'
  WHEN slug = 'supporting-sarahs-house'
    THEN 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?auto=format&fit=crop&w=1200&h=628'
  WHEN slug = 'bbbs-mentoring-program'
    THEN 'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?auto=format&fit=crop&w=1200&h=628'
  WHEN slug = 'oceanside-girls-soccer'
    THEN 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&h=628'
  END
WHERE slug IN (
  'umaine-black-bear-athletics',
  'maine-mariners-hockey',
  'maine-veterans-project-support',
  'project-linus-comfort-through-blankets',
  'supporting-sarahs-house',
  'bbbs-mentoring-program',
  'oceanside-girls-soccer'
);