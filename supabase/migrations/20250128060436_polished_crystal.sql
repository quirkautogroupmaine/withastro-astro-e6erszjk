-- Insert sample categories
INSERT INTO categories (name, slug) VALUES
  ('Sponsorship', 'sponsorship'),
  ('Donation', 'donation'),
  ('Athletics', 'athletics'),
  ('Youth Sports', 'youth-sports'),
  ('Healthcare', 'healthcare'),
  ('Education', 'education'),
  ('Veterans', 'veterans'),
  ('Community', 'community');

-- Insert sample subcategories
INSERT INTO subcategories (name, slug) VALUES
  ('Professional Sports', 'professional-sports'),
  ('College Sports', 'college-sports'),
  ('Youth Programs', 'youth-programs'),
  ('Medical Support', 'medical-support'),
  ('Educational Programs', 'educational-programs'),
  ('Veterans Support', 'veterans-support'),
  ('Community Events', 'community-events');

-- Insert sample locations
INSERT INTO locations (name, slug) VALUES
  ('Bangor', 'bangor'),
  ('Portland', 'portland'),
  ('Augusta', 'augusta'),
  ('Rockland', 'rockland'),
  ('Holden', 'holden'),
  ('Orono', 'orono'),
  ('Belfast', 'belfast');

-- Insert sample organizations
INSERT INTO organizations (name, slug, website_url, facebook_url, description) VALUES
  ('UMaine Black Bears', 'umaine-black-bears', 'https://goblackbears.com', 'https://facebook.com/UMaineAthletics', 'University of Maine Athletics Department'),
  ('Maine Mariners', 'maine-mariners', 'https://www.marinersofmaine.com', 'https://facebook.com/MarinersOfMaine', 'ECHL Professional Hockey Team'),
  ('Maine Veterans Project', 'maine-veterans-project', 'https://maineveteransproject.org', 'https://facebook.com/MaineVeteransProject', 'Supporting Maine veterans through various programs'),
  ('St. Joseph Hospital', 'st-joseph-hospital', 'https://www.stjoeshealing.org', 'https://facebook.com/StJosephBangor', 'Healthcare provider in Bangor, Maine');

-- Insert sample posts
INSERT INTO posts (title, slug, featured_image_url, excerpt, content, location_id, subcategory_id, organization_id, published, published_at) VALUES
  (
    'UMaine Black Bear Athletics',
    'umaine-black-bear-athletics',
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80',
    'As the premier sponsor of UMaine Athletics, we support student-athletes across all sports programs.',
    'Full content about UMaine Athletics sponsorship...',
    (SELECT id FROM locations WHERE slug = 'orono'),
    (SELECT id FROM subcategories WHERE slug = 'college-sports'),
    (SELECT id FROM organizations WHERE slug = 'umaine-black-bears'),
    true,
    '2024-03-15T00:00:00Z'
  ),
  (
    'Maine Mariners Hockey',
    'maine-mariners-hockey',
    'https://images.unsplash.com/photo-1515703407324-5f73fb9696b4?auto=format&fit=crop&q=80',
    'Our partnership with the Maine Mariners brings exciting professional hockey to Portland.',
    'Full content about Maine Mariners partnership...',
    (SELECT id FROM locations WHERE slug = 'portland'),
    (SELECT id FROM subcategories WHERE slug = 'professional-sports'),
    (SELECT id FROM organizations WHERE slug = 'maine-mariners'),
    true,
    '2024-03-10T00:00:00Z'
  ),
  (
    'Maine Veterans Project Support',
    'maine-veterans-project-support',
    'https://images.unsplash.com/photo-1523540939399-141cbff6a8d7?auto=format&fit=crop&q=80',
    'Supporting our veterans through home repairs, suicide prevention programs, and community reintegration initiatives.',
    'Full content about Maine Veterans Project support...',
    (SELECT id FROM locations WHERE slug = 'bangor'),
    (SELECT id FROM subcategories WHERE slug = 'veterans-support'),
    (SELECT id FROM organizations WHERE slug = 'maine-veterans-project'),
    true,
    '2024-03-12T00:00:00Z'
  );

-- Insert category associations
INSERT INTO post_categories (post_id, category_id) VALUES
  ((SELECT id FROM posts WHERE slug = 'umaine-black-bear-athletics'), (SELECT id FROM categories WHERE slug = 'sponsorship')),
  ((SELECT id FROM posts WHERE slug = 'umaine-black-bear-athletics'), (SELECT id FROM categories WHERE slug = 'athletics')),
  ((SELECT id FROM posts WHERE slug = 'maine-mariners-hockey'), (SELECT id FROM categories WHERE slug = 'sponsorship')),
  ((SELECT id FROM posts WHERE slug = 'maine-mariners-hockey'), (SELECT id FROM categories WHERE slug = 'athletics')),
  ((SELECT id FROM posts WHERE slug = 'maine-veterans-project-support'), (SELECT id FROM categories WHERE slug = 'donation')),
  ((SELECT id FROM posts WHERE slug = 'maine-veterans-project-support'), (SELECT id FROM categories WHERE slug = 'veterans'));