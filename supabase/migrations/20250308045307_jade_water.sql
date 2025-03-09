/*
  # Add Organization Fields

  1. New Fields
    - description (text) - Detailed description of the organization
    - founding_date (date) - When the organization was established
    - org_type (text) - Type of organization (e.g., "NonProfit", "CharitableOrganization")
    - tax_id (text) - Tax ID/EIN for verification
    - address_street (text) - Street address
    - address_city (text) - City
    - address_state (text) - State
    - address_zip (text) - ZIP code
    - phone (text) - Contact phone number
    - email (text) - Contact email
    - social_media (jsonb) - Store multiple social media URLs
    - service_area (text[]) - Areas served
    - mission_statement (text) - Organization's mission statement

  2. Changes
    - Adds new columns to organizations table
    - Adds validation checks for email and phone
    - Adds comment descriptions for each field

  3. Security
    - Maintains existing RLS policies
*/

-- Add new columns to organizations table
DO $$ 
BEGIN
  -- Basic Information
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'description') THEN
    ALTER TABLE organizations ADD COLUMN description text;
    COMMENT ON COLUMN organizations.description IS 'Detailed description of the organization';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'founding_date') THEN
    ALTER TABLE organizations ADD COLUMN founding_date date;
    COMMENT ON COLUMN organizations.founding_date IS 'Date when the organization was established';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'org_type') THEN
    ALTER TABLE organizations ADD COLUMN org_type text;
    COMMENT ON COLUMN organizations.org_type IS 'Type of organization (e.g., NonProfit, CharitableOrganization)';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'tax_id') THEN
    ALTER TABLE organizations ADD COLUMN tax_id text;
    COMMENT ON COLUMN organizations.tax_id IS 'Organization''s tax ID or EIN';
  END IF;

  -- Address Information
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'address_street') THEN
    ALTER TABLE organizations ADD COLUMN address_street text;
    COMMENT ON COLUMN organizations.address_street IS 'Street address';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'address_city') THEN
    ALTER TABLE organizations ADD COLUMN address_city text;
    COMMENT ON COLUMN organizations.address_city IS 'City';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'address_state') THEN
    ALTER TABLE organizations ADD COLUMN address_state text;
    COMMENT ON COLUMN organizations.address_state IS 'State';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'address_zip') THEN
    ALTER TABLE organizations ADD COLUMN address_zip text;
    COMMENT ON COLUMN organizations.address_zip IS 'ZIP code';
  END IF;

  -- Contact Information
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'phone') THEN
    ALTER TABLE organizations ADD COLUMN phone text;
    COMMENT ON COLUMN organizations.phone IS 'Contact phone number';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'email') THEN
    ALTER TABLE organizations ADD COLUMN email text;
    COMMENT ON COLUMN organizations.email IS 'Contact email address';
  END IF;

  -- Additional Information
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'social_media') THEN
    ALTER TABLE organizations ADD COLUMN social_media jsonb DEFAULT '{}';
    COMMENT ON COLUMN organizations.social_media IS 'Social media URLs in JSON format';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'service_area') THEN
    ALTER TABLE organizations ADD COLUMN service_area text[] DEFAULT '{}';
    COMMENT ON COLUMN organizations.service_area IS 'Array of areas served by the organization';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'organizations' AND column_name = 'mission_statement') THEN
    ALTER TABLE organizations ADD COLUMN mission_statement text;
    COMMENT ON COLUMN organizations.mission_statement IS 'Organization''s mission statement';
  END IF;
END $$;

-- Add validation checks
ALTER TABLE organizations
  ADD CONSTRAINT organizations_email_check 
    CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  ADD CONSTRAINT organizations_phone_check
    CHECK (phone ~* '^\+?1?\d{10,}$');

-- Add indexes for commonly searched fields
CREATE INDEX IF NOT EXISTS organizations_org_type_idx ON organizations (org_type);
CREATE INDEX IF NOT EXISTS organizations_address_city_idx ON organizations (address_city);
CREATE INDEX IF NOT EXISTS organizations_address_state_idx ON organizations (address_state);