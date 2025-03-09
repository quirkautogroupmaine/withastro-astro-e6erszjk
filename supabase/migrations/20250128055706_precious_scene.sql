/*
  # CMS Schema Setup

  1. New Tables
    - `categories` - Post categories (sponsorship, donation)
    - `subcategories` - Post subcategories (athletics, healthcare, etc.)
    - `locations` - Maine cities/towns
    - `posts` - Main content table
    - `post_categories` - Junction table for posts and categories
    - `post_images` - Gallery images for posts
    - `organizations` - Organization details

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage content
    - Add policies for public read access
*/

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  slug text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on categories"
  ON categories
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to manage categories"
  ON categories
  USING (auth.role() = 'authenticated');

-- Create subcategories table
CREATE TABLE IF NOT EXISTS subcategories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  slug text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE subcategories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on subcategories"
  ON subcategories
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to manage subcategories"
  ON subcategories
  USING (auth.role() = 'authenticated');

-- Create locations table
CREATE TABLE IF NOT EXISTS locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  slug text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on locations"
  ON locations
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to manage locations"
  ON locations
  USING (auth.role() = 'authenticated');

-- Create organizations table
CREATE TABLE IF NOT EXISTS organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  website_url text,
  facebook_url text,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on organizations"
  ON organizations
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to manage organizations"
  ON organizations
  USING (auth.role() = 'authenticated');

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  featured_image_url text NOT NULL,
  youtube_url text,
  excerpt text NOT NULL,
  content text NOT NULL,
  location_id uuid REFERENCES locations(id),
  subcategory_id uuid REFERENCES subcategories(id),
  organization_id uuid REFERENCES organizations(id),
  published boolean DEFAULT false,
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on published posts"
  ON posts
  FOR SELECT
  TO public
  USING (published = true);

CREATE POLICY "Allow authenticated users to manage posts"
  ON posts
  USING (auth.role() = 'authenticated');

-- Create post_categories junction table
CREATE TABLE IF NOT EXISTS post_categories (
  post_id uuid REFERENCES posts(id) ON DELETE CASCADE,
  category_id uuid REFERENCES categories(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (post_id, category_id)
);

ALTER TABLE post_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on post_categories"
  ON post_categories
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to manage post_categories"
  ON post_categories
  USING (auth.role() = 'authenticated');

-- Create post_images table
CREATE TABLE IF NOT EXISTS post_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid REFERENCES posts(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  caption text,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE post_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on post_images"
  ON post_images
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to manage post_images"
  ON post_images
  USING (auth.role() = 'authenticated');

-- Add updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_organizations_updated_at
  BEFORE UPDATE ON organizations
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();