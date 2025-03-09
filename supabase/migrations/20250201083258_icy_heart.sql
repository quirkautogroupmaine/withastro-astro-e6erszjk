-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO anon;

-- Grant SELECT permission on auth.users to authenticated users
GRANT SELECT ON auth.users TO authenticated;
GRANT SELECT ON auth.users TO anon;

-- Create a more secure function for role checking
CREATE OR REPLACE FUNCTION auth.get_user_role()
RETURNS text
SECURITY DEFINER
SET search_path = auth, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
  _role text;
BEGIN
  SELECT role::text INTO _role
  FROM auth.users
  WHERE id = auth.uid();
  RETURN _role;
END;
$$;

-- Update RLS policies to use the new function
DROP POLICY IF EXISTS "Super admins have full access to organizations" ON organizations;
CREATE POLICY "Super admins have full access to organizations"
ON organizations
FOR ALL
TO authenticated
USING (
  auth.get_user_role() = 'super_admin'
)
WITH CHECK (
  auth.get_user_role() = 'super_admin'
);

-- Ensure public read access is maintained
DROP POLICY IF EXISTS "Anyone can read organizations" ON organizations;
CREATE POLICY "Anyone can read organizations"
ON organizations
FOR SELECT
TO public
USING (true);

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION auth.get_user_role TO authenticated;
GRANT EXECUTE ON FUNCTION auth.get_user_role TO anon;