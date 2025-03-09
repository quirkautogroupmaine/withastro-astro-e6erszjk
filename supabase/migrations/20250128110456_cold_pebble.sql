-- Add new organizations
INSERT INTO organizations (name, slug, website_url, description) VALUES
  ('Bangor Symphony Orchestra', 'bangor-symphony', 'https://bangorsymphony.org', 'Maine''s oldest continuously operating performing arts organization'),
  ('Maine Discovery Museum', 'maine-discovery-museum', 'https://mainediscoverymuseum.org', 'The largest children''s museum north of Boston'),
  ('Eastern Maine Community College', 'emcc', 'https://www.emcc.edu', 'Comprehensive two-year public college in Bangor'),
  ('Bangor Humane Society', 'bangor-humane-society', 'https://www.bangorhumane.org', 'Animal welfare and adoption center serving the greater Bangor area'),
  ('Maine Science Festival', 'maine-science-festival', 'https://mainesciencefestival.org', 'Annual celebration of science, technology, engineering and mathematics'),
  ('Penobscot Theatre Company', 'penobscot-theatre', 'https://www.penobscottheatre.org', 'Professional theatre company in historic Bangor Opera House'),
  ('Maine Basketball Hall of Fame', 'maine-basketball-hof', 'https://www.mainebasketballhalloffame.com', 'Preserving and celebrating Maine''s rich basketball history'),
  ('Fields4Kids', 'fields4kids', 'https://fields4kids.org', 'Youth sports facility and programming organization'),
  ('Maine Junior Black Bears', 'maine-jr-black-bears', 'https://www.mainehockey.com', 'Youth hockey development program'),
  ('Challenger Learning Center', 'challenger-learning-center', 'https://www.astronaut.org', 'Space science education center');

-- Add sponsorship posts
WITH new_sponsorships AS (
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
    published_at
  ) VALUES
    (
      'Supporting the Arts: Bangor Symphony Orchestra Partnership',
      'bangor-symphony-orchestra-partnership',
      'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=1200&h=628',
      'Celebrating our partnership with Maine''s oldest continuously operating performing arts organization.',
      'Music has the power to transform lives and bring communities together. Our partnership with the Bangor Symphony Orchestra helps ensure that classical music remains accessible to all Maine residents.',
      'impact',
      '<h2>A Symphony of Community Support</h2>
      <p>Our partnership with the Bangor Symphony Orchestra represents our commitment to preserving and promoting the arts in Maine. As a major sponsor, we help make world-class musical performances accessible to our community.</p>
      
      <h3>Key Initiatives</h3>
      <ul>
        <li>Youth education programs</li>
        <li>Free community concerts</li>
        <li>Student musician scholarships</li>
        <li>Instrument lending program</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'bangor-symphony'),
      true,
      NOW() - interval '1 day'
    ),
    (
      'Maine Discovery Museum: Inspiring Young Minds',
      'maine-discovery-museum-sponsorship',
      'https://images.unsplash.com/photo-1566004100631-35d015d6a491?auto=format&fit=crop&w=1200&h=628',
      'Supporting hands-on learning and discovery at Maine''s largest children''s museum.',
      'Every child deserves the opportunity to explore, learn, and grow through hands-on experiences. The Maine Discovery Museum makes this possible for thousands of Maine children each year.',
      'impact',
      '<h2>Fostering Curiosity and Learning</h2>
      <p>Our sponsorship helps provide interactive educational experiences for children throughout Maine, making learning fun and accessible for all families.</p>
      
      <h3>Program Support</h3>
      <ul>
        <li>STEM education initiatives</li>
        <li>Free admission days</li>
        <li>School field trip programs</li>
        <li>Special needs accessibility programs</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'maine-discovery-museum'),
      true,
      NOW() - interval '2 days'
    ),
    (
      'EMCC Automotive Technology Program',
      'emcc-automotive-technology-partnership',
      'https://images.unsplash.com/photo-1504222490345-c075b6008014?auto=format&fit=crop&w=1200&h=628',
      'Investing in the future of automotive technology education at Eastern Maine Community College.',
      'The automotive industry needs skilled technicians now more than ever. Our partnership with EMCC helps train the next generation of automotive professionals.',
      'impact',
      '<h2>Training Tomorrow''s Technicians</h2>
      <p>Through our partnership with EMCC''s Automotive Technology Program, we''re helping prepare students for successful careers in the automotive industry.</p>
      
      <h3>Partnership Benefits</h3>
      <ul>
        <li>State-of-the-art equipment donations</li>
        <li>Internship opportunities</li>
        <li>Scholarship program</li>
        <li>Industry mentorship</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'emcc'),
      true,
      NOW() - interval '3 days'
    ),
    (
      'Maine Science Festival: Celebrating Innovation',
      'maine-science-festival-sponsorship',
      'https://images.unsplash.com/photo-1507413245164-6160d8298b31?auto=format&fit=crop&w=1200&h=628',
      'Supporting Maine''s largest celebration of science, technology, engineering, and mathematics.',
      'Science and innovation drive our future. The Maine Science Festival inspires the next generation of scientists, engineers, and innovators.',
      'impact',
      '<h2>Inspiring Future Innovators</h2>
      <p>Our sponsorship of the Maine Science Festival helps showcase the importance of STEM education and career opportunities in Maine.</p>
      
      <h3>Festival Highlights</h3>
      <ul>
        <li>Interactive exhibits</li>
        <li>Student workshops</li>
        <li>Tech demonstrations</li>
        <li>Career exploration events</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'maine-science-festival'),
      true,
      NOW() - interval '4 days'
    ),
    (
      'Penobscot Theatre Company Season Sponsor',
      'penobscot-theatre-season-sponsorship',
      'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?auto=format&fit=crop&w=1200&h=628',
      'Supporting professional theatre and performing arts education in downtown Bangor.',
      'Live theatre has the power to transform perspectives and bring communities together. Our partnership with Penobscot Theatre Company helps keep the arts thriving in Maine.',
      'quote',
      '<h2>Supporting Local Theatre</h2>
      <p>As the season sponsor for Penobscot Theatre Company, we help bring professional theatre productions and education programs to our community.</p>
      
      <h3>Sponsorship Impact</h3>
      <ul>
        <li>Student matinee series</li>
        <li>Theatre education programs</li>
        <li>Community outreach initiatives</li>
        <li>Facility improvements</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'penobscot-theatre'),
      true,
      NOW() - interval '5 days'
    ),
    (
      'Maine Basketball Hall of Fame Partnership',
      'maine-basketball-hof-partnership',
      'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=1200&h=628',
      'Preserving and celebrating Maine''s rich basketball history.',
      'Basketball has been a cornerstone of Maine communities for generations. The Maine Basketball Hall of Fame ensures these stories and achievements are never forgotten.',
      'impact',
      '<h2>Honoring Basketball Excellence</h2>
      <p>Our partnership helps preserve Maine''s basketball heritage and inspire future generations of players and coaches.</p>
      
      <h3>Program Support</h3>
      <ul>
        <li>Annual induction ceremony</li>
        <li>Historical preservation</li>
        <li>Youth basketball clinics</li>
        <li>Educational programs</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'maine-basketball-hof'),
      true,
      NOW() - interval '6 days'
    ),
    (
      'Fields4Kids Youth Sports Complex',
      'fields4kids-sports-complex-sponsorship',
      'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?auto=format&fit=crop&w=1200&h=628',
      'Supporting youth sports facilities and programs in the greater Bangor area.',
      'Every child deserves access to quality sports facilities and programs. Fields4Kids makes this possible for thousands of young athletes each year.',
      'impact',
      '<h2>Building Better Athletes</h2>
      <p>Our sponsorship helps provide safe, modern facilities and programs for youth sports development.</p>
      
      <h3>Facility Features</h3>
      <ul>
        <li>Multi-sport indoor facility</li>
        <li>Training programs</li>
        <li>Equipment donations</li>
        <li>Scholarship programs</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'fields4kids'),
      true,
      NOW() - interval '7 days'
    ),
    (
      'Maine Junior Black Bears Hockey Program',
      'maine-jr-black-bears-partnership',
      'https://images.unsplash.com/photo-1580748141549-71748dbe0bdc?auto=format&fit=crop&w=1200&h=628',
      'Supporting youth hockey development and education in Maine.',
      'Hockey is more than just a sport in Maine - it''s a tradition that builds character and community. The Junior Black Bears program develops both skills and values.',
      'impact',
      '<h2>Developing Young Players</h2>
      <p>Our partnership with the Maine Junior Black Bears helps develop the next generation of hockey players and leaders.</p>
      
      <h3>Program Benefits</h3>
      <ul>
        <li>Equipment assistance</li>
        <li>Skills development</li>
        <li>Travel team support</li>
        <li>Academic monitoring</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'maine-jr-black-bears'),
      true,
      NOW() - interval '8 days'
    ),
    (
      'Challenger Learning Center Space Education',
      'challenger-learning-center-partnership',
      'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=1200&h=628',
      'Inspiring the next generation of scientists and explorers through space education.',
      'Space exploration captures the imagination and inspires innovation. The Challenger Learning Center makes space science accessible and exciting for Maine students.',
      'impact',
      '<h2>Reaching for the Stars</h2>
      <p>Our partnership helps provide hands-on space science education and STEM learning opportunities.</p>
      
      <h3>Educational Programs</h3>
      <ul>
        <li>Space mission simulations</li>
        <li>STEM workshops</li>
        <li>Teacher training</li>
        <li>Summer camps</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'challenger-learning-center'),
      true,
      NOW() - interval '9 days'
    ),
    (
      'Bangor Humane Society Animal Care Initiative',
      'bangor-humane-society-partnership',
      'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=1200&h=628',
      'Supporting animal welfare and adoption services in the greater Bangor area.',
      'Every pet deserves a loving home. The Bangor Humane Society works tirelessly to make this possible for thousands of animals each year.',
      'quote',
      '<h2>Caring for Our Community''s Pets</h2>
      <p>Our partnership helps provide essential services and support for animals in need throughout our community.</p>
      
      <h3>Support Areas</h3>
      <ul>
        <li>Medical care fund</li>
        <li>Adoption programs</li>
        <li>Spay/neuter services</li>
        <li>Community education</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      (SELECT id FROM organizations WHERE slug = 'bangor-humane-society'),
      true,
      NOW() - interval '10 days'
    )
  RETURNING id
),
new_donations AS (
  INSERT INTO posts (
    title,
    slug,
    featured_image_url,
    excerpt,
    intro_text,
    intro_style,
    content,
    location_id,
    published,
    published_at
  ) VALUES
    (
      'Emergency Food Pantry Support Initiative',
      'emergency-food-pantry-support',
      'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=1200&h=628',
      'Supporting local food pantries to address immediate community needs.',
      'No one in our community should go hungry. Our emergency food pantry support helps ensure families have access to nutritious meals.',
      'impact',
      '<h2>Fighting Food Insecurity</h2>
      <p>Our donation supports local food pantries in their mission to provide emergency food assistance to families in need.</p>
      
      <h3>Impact Areas</h3>
      <ul>
        <li>Food purchases</li>
        <li>Storage equipment</li>
        <li>Distribution support</li>
        <li>Volunteer coordination</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      true,
      NOW() - interval '11 days'
    ),
    (
      'School Supplies for Success Program',
      'school-supplies-success-program',
      'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?auto=format&fit=crop&w=1200&h=628',
      'Providing essential school supplies to students in need.',
      'Every student deserves the tools they need to succeed in school. Our School Supplies for Success program helps level the playing field.',
      'impact',
      '<h2>Equipping Students for Success</h2>
      <p>Our donation provides essential school supplies to ensure all students have the tools they need to learn and grow.</p>
      
      <h3>Supplies Provided</h3>
      <ul>
        <li>Backpacks</li>
        <li>Basic supplies</li>
        <li>Art materials</li>
        <li>STEM resources</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'portland'),
      true,
      NOW() - interval '12 days'
    ),
    (
      'Winter Warmth Fund',
      'winter-warmth-fund',
      'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=1200&h=628',
      'Helping Maine families stay warm during winter months.',
      'Maine winters can be challenging, especially for families struggling with heating costs. Our Winter Warmth Fund provides crucial assistance when it''s needed most.',
      'impact',
      '<h2>Keeping Families Warm</h2>
      <p>Our donation helps provide heating assistance and winter clothing to families in need.</p>
      
      <h3>Assistance Areas</h3>
      <ul>
        <li>Heating fuel assistance</li>
        <li>Winter clothing</li>
        <li>Emergency repairs</li>
        <li>Weatherization support</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'augusta'),
      true,
      NOW() - interval '13 days'
    ),
    (
      'Youth Mental Health Support',
      'youth-mental-health-support',
      'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?auto=format&fit=crop&w=1200&h=628',
      'Supporting mental health resources for Maine youth.',
      'Mental health support is essential for young people''s wellbeing. Our donation helps ensure access to crucial mental health services.',
      'quote',
      '<h2>Supporting Youth Wellness</h2>
      <p>Our contribution helps provide mental health resources and support services for young people in our community.</p>
      
      <h3>Program Support</h3>
      <ul>
        <li>Counseling services</li>
        <li>Crisis intervention</li>
        <li>Support groups</li>
        <li>Educational programs</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      true,
      NOW() - interval '14 days'
    ),
    (
      'Senior Technology Access Program',
      'senior-technology-access',
      'https://images.unsplash.com/photo-1573497019236-17f8177b81e8?auto=format&fit=crop&w=1200&h=628',
      'Helping seniors stay connected through technology.',
      'Technology access is crucial for seniors to stay connected with family and access essential services. Our program helps bridge the digital divide.',
      'impact',
      '<h2>Connecting Seniors</h2>
      <p>Our donation provides technology access and training to help seniors stay connected and independent.</p>
      
      <h3>Program Elements</h3>
      <ul>
        <li>Device donations</li>
        <li>Internet access</li>
        <li>Training sessions</li>
        <li>Technical support</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'portland'),
      true,
      NOW() - interval '15 days'
    ),
    (
      'Veterans Housing Assistance',
      'veterans-housing-assistance',
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&h=628',
      'Supporting housing solutions for Maine veterans.',
      'Our veterans deserve stable, safe housing. This program helps ensure they have a place to call home.',
      'impact',
      '<h2>Housing Our Heroes</h2>
      <p>Our donation supports housing assistance and home repairs for veterans in need.</p>
      
      <h3>Assistance Areas</h3>
      <ul>
        <li>Emergency repairs</li>
        <li>Accessibility modifications</li>
        <li>Utility assistance</li>
        <li>Housing placement</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'augusta'),
      true,
      NOW() - interval '16 days'
    ),
    (
      'Community Garden Initiative',
      'community-garden-initiative',
      'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?auto=format&fit=crop&w=1200&h=628',
      'Supporting local food security through community gardens.',
      'Community gardens provide fresh food access and bring neighbors together. Our support helps these vital spaces thrive.',
      'impact',
      '<h2>Growing Community</h2>
      <p>Our donation helps establish and maintain community gardens throughout Maine.</p>
      
      <h3>Program Support</h3>
      <ul>
        <li>Garden development</li>
        <li>Tool libraries</li>
        <li>Education programs</li>
        <li>Seed donations</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      true,
      NOW() - interval '17 days'
    ),
    (
      'Emergency Medical Transport Fund',
      'emergency-medical-transport',
      'https://images.unsplash.com/photo-1587745416684-47953f16f02f?auto=format&fit=crop&w=1200&h=628',
      'Supporting emergency medical transportation for rural communities.',
      'In rural Maine, access to emergency medical care can be challenging. Our fund helps ensure transportation is available when needed most.',
      'impact',
      '<h2>Critical Care Access</h2>
      <p>Our donation supports emergency medical transportation services in rural Maine communities.</p>
      
      <h3>Support Areas</h3>
      <ul>
        <li>Equipment upgrades</li>
        <li>Training programs</li>
        <li>Vehicle maintenance</li>
        <li>Patient assistance</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'augusta'),
      true,
      NOW() - interval '18 days'
    ),
    (
      'Adult Education Scholarship Fund',
      'adult-education-scholarship',
      'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?auto=format&fit=crop&w=1200&h=628',
      'Supporting continuing education opportunities for adults.',
      'It''s never too late to learn. Our scholarship fund helps adults pursue education and career advancement.',
      'quote',
      '<h2>Lifelong Learning</h2>
      <p>Our donation provides scholarships for adult learners pursuing education and career training.</p>
      
      <h3>Scholarship Support</h3>
      <ul>
        <li>Tuition assistance</li>
        <li>Book stipends</li>
        <li>Technology access</li>
        <li>Career counseling</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'portland'),
      true,
      NOW() - interval '19 days'
    ),
    (
      'Youth Arts Access Program',
      'youth-arts-access',
      'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?auto=format&fit=crop&w=1200&h=628',
      'Making arts education accessible to all young people.',
      'Arts education enriches lives and develops creativity. Our program ensures all young people have access to arts opportunities.',
      'impact',
      '<h2>Inspiring Creativity</h2>
      <p>Our donation supports arts education and creative opportunities for youth throughout Maine.</p>
      
      <h3>Program Elements</h3>
      <ul>
        <li>Art supplies</li>
        <li>Class scholarships</li>
        <li>Performance opportunities</li>
        <li>Teaching artists</li>
      </ul>',
      (SELECT id FROM locations WHERE slug = 'bangor'),
      true,
      NOW() - interval '20 days'
    )
  RETURNING id
)
-- Add category associations
INSERT INTO post_categories (post_id, category_id)
SELECT id, (SELECT id FROM categories WHERE slug = 'sponsorship')
FROM new_sponsorships
UNION ALL
SELECT id, (SELECT id FROM categories WHERE slug = 'donation')
FROM new_donations;