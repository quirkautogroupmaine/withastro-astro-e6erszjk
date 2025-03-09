-- Grant necessary permissions to authenticated users to read their own role
CREATE POLICY "Users can read own data"
ON auth.users
FOR SELECT
TO authenticated
USING (
  auth.uid() = id
);

-- Allow public access to check roles (needed for RLS policies)
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Create a secure view for role checking
CREATE OR REPLACE VIEW auth.user_roles AS
SELECT 
  id,
  role,
  email
FROM auth.users
WHERE role IS NOT NULL;

-- Grant access to the view
GRANT SELECT ON auth.user_roles TO authenticated;
GRANT SELECT ON auth.user_roles TO anon;

-- Update RLS policies to use the view
CREATE OR REPLACE FUNCTION auth.check_user_role(required_role text)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM auth.user_roles 
    WHERE id = auth.uid() 
    AND role::text = required_role
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update existing policies to use the new function
DROP POLICY IF EXISTS "Super admins have full access to organizations" ON organizations;
CREATE POLICY "Super admins have full access to organizations"
ON organizations
FOR ALL
TO authenticated
USING (
  auth.check_user_role('super_admin')
)
WITH CHECK (
  auth.check_user_role('super_admin')
);

-- Add policy for public read access to organizations
CREATE POLICY "Anyone can read organizations"
ON organizations
FOR SELECT
TO public
USING (true);