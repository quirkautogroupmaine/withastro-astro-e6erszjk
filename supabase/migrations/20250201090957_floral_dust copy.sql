/*
  # Add Quirk Locations Table

  1. New Tables
    - `quirk_locations`
      - `id` (uuid, primary key)
      - `title` (text, required)
      - `location_logo` (text, optional)
      - `location_featured_image` (text, optional)
      - `youtube_profile` (text, optional)
      - `physical_address` (text, required)
      - `city` (text, required)
      - `state` (text, required)
      - `zip_code` (text, required)
      - `website` (text, optional)
      - `facebook` (text, optional)
      - `instagram` (text, optional)
      - `gmb` (text, optional) - Google My Business URL
      - `content_description` (text, optional)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `slug` (text, unique)

  2. Changes
    - Add `quirk_location_id` to posts table
    - Add foreign key constraint

  3. Security
    - Enable RLS
    - Add policies for public read access
    - Add policies for authenticated users
*/

-- Create quirk_locations table
CREATE TABLE quirk_locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  location_logo text,
  location_featured_image text,
  youtube_profile text,
  physical_address text NOT NULL,
  city text NOT NULL,
  state text NOT NULL,
  zip_code text NOT NULL,
  website text,
  facebook text,
  instagram text,
  gmb text,
  content_description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  slug text UNIQUE NOT NULL
);

-- Add comments for documentation
COMMENT ON TABLE quirk_locations IS 'Quirk Auto Group dealership and business locations';
COMMENT ON COLUMN quirk_locations.location_logo IS 'URL to location logo image';
COMMENT ON COLUMN quirk_locations.location_featured_image IS 'URL to featured image for location';
COMMENT ON COLUMN quirk_locations.youtube_profile IS 'YouTube channel URL for location';
COMMENT ON COLUMN quirk_locations.gmb IS 'Google My Business profile URL';
COMMENT ON COLUMN quirk_locations.slug IS 'URL-friendly version of location title';

-- Add quirk_location_id to posts table
ALTER TABLE posts
ADD COLUMN quirk_location_id uuid REFERENCES quirk_locations(id);

-- Add index for performance
CREATE INDEX idx_posts_quirk_location ON posts(quirk_location_id);
CREATE INDEX idx_quirk_locations_slug ON quirk_locations(slug);

-- Enable RLS
ALTER TABLE quirk_locations ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Enable read access for all users"
ON quirk_locations
FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable all access for authenticated users"
ON quirk_locations
FOR ALL
TO authenticated
USING (
  auth.role() = 'authenticated'
)
WITH CHECK (
  auth.role() = 'authenticated'
);

-- Create updated_at trigger
CREATE TRIGGER set_quirk_locations_updated_at
  BEFORE UPDATE ON quirk_locations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();