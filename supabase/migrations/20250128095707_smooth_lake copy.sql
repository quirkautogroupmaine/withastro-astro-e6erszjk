/*
  # Add Husson University Athletics Sponsorship

  1. New Organization
    - Add Husson University to organizations table
  
  2. New Post
    - Create sponsorship post with intro quote, gallery, and content
    - Add category associations
*/

-- Add Husson University to organizations
INSERT INTO organizations (name, slug, website_url, description) VALUES
  ('Husson University Athletics', 'husson-athletics', 'https://hussoneagles.com', 'NCAA Division III athletics program at Husson University, featuring 22 varsity sports teams and over 500 student-athletes.');

-- Create the sponsorship post
INSERT INTO posts (
  title,
  slug,
  featured_image_url,
  excerpt,
  intro_text,
  intro_style,
  content,
  location_id,
  organization_id,
  published,
  published_at,
  gallery_items
) VALUES (
  'Husson University Eagles: Soaring to New Heights',
  'husson-university-eagles-partnership',
  'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=1200&h=628',
  'Supporting academic and athletic excellence at Husson University through our comprehensive athletics partnership.',
  '"The partnership between Husson Athletics and Quirk Auto Group represents more than just sponsorship – it''s about creating opportunities for student-athletes to excel both on the field and in the classroom. Together, we''re building champions for life."',
  'quote',
  '<h2>Empowering Student-Athletes</h2>
<p>Our partnership with Husson University Athletics embodies our commitment to fostering excellence in both sports and academics. As the premier sponsor of Husson Eagles athletics, we''re proud to support over 500 student-athletes across 22 varsity sports programs.</p>

<h3>Partnership Highlights</h3>
<ul>
  <li><strong>Athletic Scholarships</strong> supporting deserving student-athletes</li>
  <li><strong>Facility Improvements</strong> including new scoreboards and equipment</li>
  <li><strong>Transportation Support</strong> for away games and tournaments</li>
  <li><strong>Game Day Experience</strong> enhancements for fans and athletes</li>
</ul>

<h3>Community Impact</h3>
<p>Through this partnership, we''ve helped:</p>
<ul>
  <li>Support <strong>22 varsity sports programs</strong></li>
  <li>Enable participation for <strong>500+ student-athletes</strong></li>
  <li>Fund facility improvements worth <strong>$100,000+</strong></li>
  <li>Provide <strong>10 annual scholarships</strong> for student-athletes</li>
  <li>Support <strong>youth sports clinics</strong> reaching hundreds of local children</li>
</ul>

<h3>Academic Excellence</h3>
<p>Our support extends beyond athletics to ensure student-athletes succeed in their academic pursuits. Key initiatives include:</p>
<ul>
  <li>Academic support programs and tutoring</li>
  <li>Career development workshops</li>
  <li>Leadership training opportunities</li>
  <li>Internship programs at Quirk Auto Group</li>
</ul>

<h3>Looking Forward</h3>
<p>As we continue to grow our partnership with Husson University Athletics, we remain committed to:</p>
<ul>
  <li>Expanding scholarship opportunities</li>
  <li>Enhancing athletic facilities</li>
  <li>Supporting student-athlete development programs</li>
  <li>Strengthening community engagement initiatives</li>
</ul>

<p>Together with Husson University, we''re not just supporting athletics – we''re investing in the future leaders of Maine''s communities.</p>',
  (SELECT id FROM locations WHERE slug = 'bangor'),
  (SELECT id FROM organizations WHERE slug = 'husson-athletics'),
  true,
  NOW(),
  '[
    {
      "type": "image",
      "url": "https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=800&h=600",
      "caption": "Husson Eagles Football in Action"
    },
    {
      "type": "youtube",
      "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "title": "Husson Athletics: A Tradition of Excellence"
    },
    {
      "type": "image",
      "url": "https://images.unsplash.com/photo-1519766304817-4f37bda74a26?auto=format&fit=crop&w=800&h=600",
      "caption": "Basketball Game at Newman Gymnasium"
    },
    {
      "type": "image",
      "url": "https://images.unsplash.com/photo-1580748141549-71748dbe0bdc?auto=format&fit=crop&w=800&h=600",
      "caption": "Student-Athletes Giving Back to the Community"
    },
    {
      "type": "youtube",
      "url": "https://www.youtube.com/watch?v=jNQXAC9IVRw",
      "title": "Meet Our Student-Athletes: Stories of Determination"
    }
  ]'::jsonb
);

-- Add category associations
INSERT INTO post_categories (post_id, category_id)
SELECT p.id, c.id
FROM posts p
CROSS JOIN categories c
WHERE p.slug = 'husson-university-eagles-partnership'
AND c.slug IN ('sponsorship', 'athletics', 'education');