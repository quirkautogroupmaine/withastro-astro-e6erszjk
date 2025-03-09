-- Add logo_url column to organizations table
ALTER TABLE organizations 
ADD COLUMN IF NOT EXISTS logo_url text;

-- Add comment for documentation
COMMENT ON COLUMN organizations.logo_url IS 'URL to organization''s logo image stored in Supabase storage';