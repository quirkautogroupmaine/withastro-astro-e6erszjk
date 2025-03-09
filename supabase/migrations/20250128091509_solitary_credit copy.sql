-- Insert additional organizations
INSERT INTO organizations (name, slug, website_url, description) VALUES
  ('Pine Tree Camp', 'pine-tree-camp', 'https://www.pinetreesociety.org', 'Providing Maine children and adults with disabilities extraordinary outdoor experiences'),
  ('Good Shepherd Food Bank', 'good-shepherd-food-bank', 'https://www.gsfb.org', 'Working to eliminate hunger in Maine'),
  ('Maine Cancer Foundation', 'maine-cancer-foundation', 'https://mainecancer.org', 'Supporting cancer prevention, early detection, and access to care'),
  ('Travis Mills Foundation', 'travis-mills-foundation', 'https://travismillsfoundation.org', 'Supporting recalibrated veterans and their families'),
  ('Maine Audubon', 'maine-audubon', 'https://maineaudubon.org', 'Conserving Maine''s wildlife and wildlife habitat'),
  ('Maine Music Society', 'maine-music-society', 'https://www.mainemusicsociety.org', 'Promoting excellence in music performance and education'),
  ('Maine Adaptive Sports', 'maine-adaptive-sports', 'https://www.maineadaptive.org', 'Year-round adaptive recreation for adults and children with disabilities'),
  ('Camp Sunshine', 'camp-sunshine', 'https://www.campsunshine.org', 'Retreat for children with life-threatening illnesses and their families'),
  ('Maine State Music Theatre', 'maine-state-music-theatre', 'https://msmt.org', 'Professional musical theatre in Brunswick'),
  ('Maine Children''s Cancer Program', 'maine-childrens-cancer-program', 'https://mainehealth.org/maine-medical-center/services/children/childrens-cancer-program', 'Comprehensive care for children with cancer and blood disorders');

-- Insert sponsorship posts
INSERT INTO posts (title, slug, featured_image_url, excerpt, content, location_id, organization_id, published, published_at) VALUES
  (
    'Pine Tree Camp Summer Programs',
    'pine-tree-camp-summer-programs',
    'https://images.unsplash.com/photo-1596496181848-3091d4878b24?auto=format&fit=crop&w=1200&h=628',
    'Supporting accessible summer camp experiences for children and adults with disabilities.',
    '<h2>Creating Inclusive Outdoor Experiences</h2><p>Our sponsorship enables Pine Tree Camp to provide barrier-free access to Maine''s outdoors...</p>',
    (SELECT id FROM locations WHERE slug = 'augusta'),
    (SELECT id FROM organizations WHERE slug = 'pine-tree-camp'),
    true,
    '2024-01-15T00:00:00Z'
  ),
  (
    'Good Shepherd Food Bank Partnership',
    'good-shepherd-food-bank-partnership',
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=1200&h=628',
    'Joining forces to combat food insecurity across Maine communities.',
    '<h2>Fighting Hunger Together</h2><p>Through our partnership with Good Shepherd Food Bank, we''re helping to ensure no Mainer goes hungry...</p>',
    (SELECT id FROM locations WHERE slug = 'bangor'),
    (SELECT id FROM organizations WHERE slug = 'good-shepherd-food-bank'),
    true,
    '2024-01-20T00:00:00Z'
  ),
  (
    'Maine Cancer Foundation Sponsorship',
    'maine-cancer-foundation-sponsorship',
    'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=1200&h=628',
    'Supporting cancer research and patient care initiatives in Maine.',
    '<h2>Supporting Cancer Research</h2><p>Our sponsorship helps fund vital cancer research and support services throughout Maine...</p>',
    (SELECT id FROM locations WHERE slug = 'portland'),
    (SELECT id FROM organizations WHERE slug = 'maine-cancer-foundation'),
    true,
    '2024-01-25T00:00:00Z'
  ),
  (
    'Travis Mills Foundation Veterans Retreat',
    'travis-mills-foundation-veterans-retreat',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=1200&h=628',
    'Supporting recalibrated veterans and their families through adaptive activities.',
    '<h2>Supporting Our Veterans</h2><p>The Travis Mills Foundation provides life-changing experiences for veterans and their families...</p>',
    (SELECT id FROM locations WHERE slug = 'augusta'),
    (SELECT id FROM organizations WHERE slug = 'travis-mills-foundation'),
    true,
    '2024-02-01T00:00:00Z'
  ),
  (
    'Maine Audubon Conservation Programs',
    'maine-audubon-conservation-programs',
    'https://images.unsplash.com/photo-1444464666168-49d633b86797?auto=format&fit=crop&w=1200&h=628',
    'Protecting Maine''s wildlife and natural habitats through education and conservation.',
    '<h2>Preserving Maine''s Natural Heritage</h2><p>Our partnership with Maine Audubon supports critical conservation efforts...</p>',
    (SELECT id FROM locations WHERE slug = 'portland'),
    (SELECT id FROM organizations WHERE slug = 'maine-audubon'),
    true,
    '2024-02-05T00:00:00Z'
  );

-- Insert donation posts
INSERT INTO posts (title, slug, featured_image_url, excerpt, content, location_id, organization_id, published, published_at) VALUES
  (
    'Maine Music Society Support',
    'maine-music-society-support',
    'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?auto=format&fit=crop&w=1200&h=628',
    'Fostering musical excellence and education in Maine communities.',
    '<h2>Enriching Lives Through Music</h2><p>Our support helps bring exceptional musical performances and education to Maine communities...</p>',
    (SELECT id FROM locations WHERE slug = 'augusta'),
    (SELECT id FROM organizations WHERE slug = 'maine-music-society'),
    true,
    '2024-02-10T00:00:00Z'
  ),
  (
    'Maine Adaptive Sports Equipment Drive',
    'maine-adaptive-sports-equipment',
    'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?auto=format&fit=crop&w=1200&h=628',
    'Providing adaptive sports equipment for year-round activities.',
    '<h2>Making Sports Accessible</h2><p>Our donation helps provide specialized equipment for adaptive sports programs...</p>',
    (SELECT id FROM locations WHERE slug = 'portland'),
    (SELECT id FROM organizations WHERE slug = 'maine-adaptive-sports'),
    true,
    '2024-02-15T00:00:00Z'
  ),
  (
    'Camp Sunshine Family Support',
    'camp-sunshine-family-support',
    'https://images.unsplash.com/photo-1472898965229-f9b06b9c9bbe?auto=format&fit=crop&w=1200&h=628',
    'Supporting families affected by life-threatening childhood illnesses.',
    '<h2>Creating Moments of Joy</h2><p>Our donation helps provide respite and support for families facing serious medical challenges...</p>',
    (SELECT id FROM locations WHERE slug = 'portland'),
    (SELECT id FROM organizations WHERE slug = 'camp-sunshine'),
    true,
    '2024-02-20T00:00:00Z'
  ),
  (
    'Maine State Music Theatre Season Support',
    'maine-state-music-theatre-support',
    'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?auto=format&fit=crop&w=1200&h=628',
    'Supporting professional musical theatre productions in Brunswick.',
    '<h2>Bringing Broadway to Maine</h2><p>Our donation helps bring world-class musical theatre performances to Maine audiences...</p>',
    (SELECT id FROM locations WHERE slug = 'portland'),
    (SELECT id FROM organizations WHERE slug = 'maine-state-music-theatre'),
    true,
    '2024-02-25T00:00:00Z'
  ),
  (
    'Maine Children''s Cancer Program Support',
    'maine-childrens-cancer-program-support',
    'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?auto=format&fit=crop&w=1200&h=628',
    'Supporting comprehensive care for children with cancer.',
    '<h2>Fighting Childhood Cancer</h2><p>Our donation supports vital research and care for children battling cancer...</p>',
    (SELECT id FROM locations WHERE slug = 'portland'),
    (SELECT id FROM organizations WHERE slug = 'maine-childrens-cancer-program'),
    true,
    '2024-03-01T00:00:00Z'
  );

-- Insert category associations for new posts
INSERT INTO post_categories (post_id, category_id)
SELECT posts.id, categories.id
FROM posts
CROSS JOIN categories
WHERE posts.slug IN (
  'pine-tree-camp-summer-programs',
  'good-shepherd-food-bank-partnership',
  'maine-cancer-foundation-sponsorship',
  'travis-mills-foundation-veterans-retreat',
  'maine-audubon-conservation-programs'
) AND categories.slug = 'sponsorship';

INSERT INTO post_categories (post_id, category_id)
SELECT posts.id, categories.id
FROM posts
CROSS JOIN categories
WHERE posts.slug IN (
  'maine-music-society-support',
  'maine-adaptive-sports-equipment',
  'camp-sunshine-family-support',
  'maine-state-music-theatre-support',
  'maine-childrens-cancer-program-support'
) AND categories.slug = 'donation';