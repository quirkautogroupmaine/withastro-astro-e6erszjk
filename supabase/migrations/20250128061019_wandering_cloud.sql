/*
  # Add more sample posts and organizations

  1. New Organizations
    - Project Linus
    - Sarah's House
    - Big Brothers Big Sisters
    - Oceanside High School

  2. New Posts
    - Project Linus post
    - Sarah's House post
    - Big Brothers Big Sisters post
    - Oceanside High School Girls Soccer post
*/

-- Insert additional organizations
INSERT INTO organizations (name, slug, website_url, description) VALUES
  ('Project Linus', 'project-linus', 'https://projectlinus.org', 'Providing handmade blankets to children in need'),
  ('Sarah''s House', 'sarahs-house', 'https://sarahshouseofmaine.org', 'Cancer hospitality house serving patients and families'),
  ('Big Brothers Big Sisters', 'bbbs', 'https://bbbsmaine.org', 'Youth mentoring organization'),
  ('Oceanside High School', 'oceanside-high-school', 'https://rsu13.org', 'Public high school in Rockland, Maine');

-- Insert additional posts
INSERT INTO posts (title, slug, featured_image_url, excerpt, content, location_id, organization_id, published, published_at) VALUES
  (
    'Project Linus: Comfort Through Blankets',
    'project-linus-comfort-through-blankets',
    'https://images.unsplash.com/photo-1445991842772-097fea258e7b?auto=format&fit=crop&q=80',
    'Providing handmade blankets to children in need, bringing comfort and security to those facing challenging situations.',
    'Full content about Project Linus support...',
    (SELECT id FROM locations WHERE slug = 'portland'),
    (SELECT id FROM organizations WHERE slug = 'project-linus'),
    true,
    '2024-03-08T00:00:00Z'
  ),
  (
    'Supporting Sarah''s House',
    'supporting-sarahs-house',
    'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?auto=format&fit=crop&q=80',
    'Providing a home away from home for cancer patients and their families while receiving treatment in Bangor.',
    'Full content about Sarah''s House support...',
    (SELECT id FROM locations WHERE slug = 'holden'),
    (SELECT id FROM organizations WHERE slug = 'sarahs-house'),
    true,
    '2024-02-20T00:00:00Z'
  ),
  (
    'Big Brothers Big Sisters Mentoring Program',
    'bbbs-mentoring-program',
    'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?auto=format&fit=crop&q=80',
    'Empowering youth through one-to-one mentoring relationships that change lives for the better, forever.',
    'Full content about BBBS support...',
    (SELECT id FROM locations WHERE slug = 'augusta'),
    (SELECT id FROM organizations WHERE slug = 'bbbs'),
    true,
    '2024-02-25T00:00:00Z'
  ),
  (
    'Oceanside High School Girls Soccer',
    'oceanside-girls-soccer',
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80',
    'Supporting female student-athletes through equipment donations and facility improvements in Rockland.',
    'Full content about Oceanside Girls Soccer support...',
    (SELECT id FROM locations WHERE slug = 'rockland'),
    (SELECT id FROM organizations WHERE slug = 'oceanside-high-school'),
    true,
    '2024-02-15T00:00:00Z'
  );

-- Insert category associations for new posts
INSERT INTO post_categories (post_id, category_id) VALUES
  ((SELECT id FROM posts WHERE slug = 'project-linus-comfort-through-blankets'), (SELECT id FROM categories WHERE slug = 'donation')),
  ((SELECT id FROM posts WHERE slug = 'project-linus-comfort-through-blankets'), (SELECT id FROM categories WHERE slug = 'community')),
  ((SELECT id FROM posts WHERE slug = 'supporting-sarahs-house'), (SELECT id FROM categories WHERE slug = 'donation')),
  ((SELECT id FROM posts WHERE slug = 'supporting-sarahs-house'), (SELECT id FROM categories WHERE slug = 'healthcare')),
  ((SELECT id FROM posts WHERE slug = 'bbbs-mentoring-program'), (SELECT id FROM categories WHERE slug = 'donation')),
  ((SELECT id FROM posts WHERE slug = 'bbbs-mentoring-program'), (SELECT id FROM categories WHERE slug = 'education')),
  ((SELECT id FROM posts WHERE slug = 'oceanside-girls-soccer'), (SELECT id FROM categories WHERE slug = 'donation')),
  ((SELECT id FROM posts WHERE slug = 'oceanside-girls-soccer'), (SELECT id FROM categories WHERE slug = 'youth-sports'));