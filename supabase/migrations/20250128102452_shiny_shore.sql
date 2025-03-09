-- First clean up any existing news posts
DELETE FROM post_categories
WHERE post_id IN (
  SELECT id FROM posts 
  WHERE slug IN (
    'all-new-2024-chevrolet-silverado-ev-arrives',
    'quirk-subaru-new-facility-announcement',
    'sarah-johnson-promotion-announcement',
    'mobile-maintenance-service-launch',
    'new-mobile-app-launch'
  )
);

DELETE FROM posts 
WHERE slug IN (
  'all-new-2024-chevrolet-silverado-ev-arrives',
  'quirk-subaru-new-facility-announcement',
  'sarah-johnson-promotion-announcement',
  'mobile-maintenance-service-launch',
  'new-mobile-app-launch'
);

-- Insert news posts
WITH new_posts AS (
  INSERT INTO posts (title, slug, featured_image_url, excerpt, content, location_id, published, published_at) VALUES
    (
      'All-New 2024 Chevrolet Silverado EV Arrives at Quirk',
      'all-new-2024-chevrolet-silverado-ev-arrives',
      'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&h=628',
      'Experience the future of trucks with the all-electric Chevrolet Silverado EV, now available at Quirk Chevrolet locations.',
      '<h2>The Future of Trucks Has Arrived</h2>
      <p>We''re excited to announce the arrival of the all-new 2024 Chevrolet Silverado EV at our dealerships. This revolutionary electric truck combines Chevrolet''s legendary capability with zero-emission technology.</p>
      
      <h3>Key Features</h3>
      <ul>
        <li>Up to 400 miles of range on a single charge</li>
        <li>Up to 10,000 lbs of towing capacity</li>
        <li>Advanced Super Cruise hands-free driving technology</li>
        <li>Innovative Multi-Flex Midgate with pass-through capability</li>
      </ul>
      
      <h3>Available Now</h3>
      <p>Visit any Quirk Chevrolet location to experience the Silverado EV firsthand. Our trained product specialists are ready to showcase all the innovative features and help you make the switch to electric.</p>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      true,
      '2024-03-15T09:00:00Z'
    ),
    (
      'Quirk Subaru Moving to New State-of-the-Art Facility',
      'quirk-subaru-new-facility-announcement',
      'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?auto=format&fit=crop&w=1200&h=628',
      'Announcing our new Subaru dealership location featuring expanded service capacity and enhanced customer amenities.',
      '<h2>Expanding to Serve You Better</h2>
      <p>We''re thrilled to announce that Quirk Subaru will be moving to a brand new, state-of-the-art facility in Bangor. This move represents our commitment to providing the best possible experience for our customers.</p>
      
      <h3>New Facility Features</h3>
      <ul>
        <li>30,000 square foot modern showroom</li>
        <li>24 service bays with latest diagnostic equipment</li>
        <li>Comfortable customer lounge with workspace</li>
        <li>Electric vehicle charging stations</li>
        <li>Children''s play area</li>
        <li>Enhanced parts department</li>
      </ul>
      
      <h3>Location & Timeline</h3>
      <p>The new facility will be located at 123 Main Street, with construction scheduled to complete in Fall 2024. Our current location will remain fully operational until the move.</p>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      true,
      '2024-03-10T10:00:00Z'
    ),
    (
      'Sarah Johnson Promoted to General Manager of Quirk Chevrolet Portland',
      'sarah-johnson-promotion-announcement',
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=1200&h=628',
      'Celebrating the promotion of Sarah Johnson, a 15-year veteran of Quirk Auto Group, to General Manager of our Portland location.',
      '<h2>A Well-Deserved Promotion</h2>
      <p>We''re proud to announce the promotion of Sarah Johnson to General Manager of Quirk Chevrolet Portland. Sarah''s 15-year journey with Quirk Auto Group exemplifies our commitment to developing talent from within.</p>
      
      <h3>Sarah''s Journey</h3>
      <p>Starting as a sales consultant in 2009, Sarah has consistently demonstrated exceptional leadership and customer service skills. Her roles have included:</p>
      <ul>
        <li>Sales Consultant (2009-2012)</li>
        <li>Finance Manager (2012-2015)</li>
        <li>Sales Manager (2015-2020)</li>
        <li>Operations Manager (2020-2024)</li>
      </ul>
      
      <h3>Vision for the Future</h3>
      <p>Under Sarah''s leadership, Quirk Chevrolet Portland will continue its focus on exceptional customer service while implementing new digital initiatives to enhance the car-buying experience.</p>',
      (SELECT id FROM locations WHERE slug = 'portland'),
      true,
      '2024-03-05T14:00:00Z'
    ),
    (
      'Quirk Service Centers Now Offering Mobile Maintenance',
      'mobile-maintenance-service-launch',
      'https://images.unsplash.com/photo-1530046339160-ce3e530c7d2f?auto=format&fit=crop&w=1200&h=628',
      'Introducing our new mobile maintenance service - professional vehicle maintenance at your home or office.',
      '<h2>Service at Your Convenience</h2>
      <p>We''re excited to launch our new mobile maintenance service, bringing Quirk''s professional service technicians directly to your location.</p>
      
      <h3>Available Services</h3>
      <ul>
        <li>Oil changes and filter replacements</li>
        <li>Tire rotations and balancing</li>
        <li>Multi-point vehicle inspections</li>
        <li>Battery testing and replacement</li>
        <li>Brake inspections</li>
      </ul>
      
      <h3>How It Works</h3>
      <p>Simply schedule your service through our website or mobile app, and our fully-equipped service van will come to your location. All work is performed by certified technicians using genuine OEM parts.</p>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      true,
      '2024-02-28T11:00:00Z'
    ),
    (
      'Quirk Auto Group Launches New Mobile App',
      'new-mobile-app-launch',
      'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=1200&h=628',
      'Introducing our new mobile app for seamless vehicle shopping, service scheduling, and ownership experience.',
      '<h2>Your Dealership in Your Pocket</h2>
      <p>We''re proud to announce the launch of the new Quirk Auto Group mobile app, designed to make your car buying and ownership experience more convenient than ever.</p>
      
      <h3>App Features</h3>
      <ul>
        <li>Browse our entire inventory with real-time updates</li>
        <li>Schedule service appointments</li>
        <li>Track your vehicle''s maintenance history</li>
        <li>Access digital owner''s manuals</li>
        <li>Receive exclusive offers and updates</li>
        <li>Connect with your preferred dealership</li>
      </ul>
      
      <h3>Download Now</h3>
      <p>The Quirk Auto Group app is available for free download on both iOS and Android platforms.</p>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      true,
      '2024-02-20T13:00:00Z'
    )
  RETURNING id, slug
)
INSERT INTO post_categories (post_id, category_id)
SELECT 
  new_posts.id,
  categories.id
FROM new_posts
CROSS JOIN categories
WHERE 
  (new_posts.slug = 'all-new-2024-chevrolet-silverado-ev-arrives' AND categories.slug IN ('news', 'vehicle-launch'))
  OR (new_posts.slug = 'quirk-subaru-new-facility-announcement' AND categories.slug IN ('news', 'company-update'))
  OR (new_posts.slug = 'sarah-johnson-promotion-announcement' AND categories.slug IN ('news', 'employee-news'))
  OR (new_posts.slug = 'mobile-maintenance-service-launch' AND categories.slug IN ('news', 'company-update'))
  OR (new_posts.slug = 'new-mobile-app-launch' AND categories.slug IN ('news', 'company-update'));