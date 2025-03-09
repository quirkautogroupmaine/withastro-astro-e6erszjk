-- Create super admin role
CREATE TYPE auth.role AS ENUM ('super_admin', 'admin', 'editor');

-- Add role column to auth.users if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'auth' 
    AND table_name = 'users' 
    AND column_name = 'role') 
  THEN
    ALTER TABLE auth.users ADD COLUMN role auth.role;
  END IF;
END $$;

-- Create super admin user if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE email = 'quirkautogroupmaine@gmail.com'
  ) THEN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      recovery_sent_at,
      last_sign_in_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'super_admin',
      'quirkautogroupmaine@gmail.com',
      crypt('QuirkAuto2024!', gen_salt('bf')),
      now(),
      now(),
      now(),
      '{"provider": "email", "providers": ["email"]}',
      '{"role": "super_admin"}',
      now(),
      now(),
      '',
      '',
      '',
      ''
    );
  END IF;
END $$;

-- Add RLS policies for super admin
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Super admins have full access to posts"
ON posts
FOR ALL
TO authenticated
USING (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
);

-- Add similar policies for other tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins have full access to categories"
ON categories
FOR ALL
TO authenticated
USING (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
);

ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins have full access to locations"
ON locations
FOR ALL
TO authenticated
USING (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
);

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins have full access to organizations"
ON organizations
FOR ALL
TO authenticated
USING (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
);

ALTER TABLE post_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins have full access to post_categories"
ON post_categories
FOR ALL
TO authenticated
USING (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
);

ALTER TABLE post_images ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins have full access to post_images"
ON post_images
FOR ALL
TO authenticated
USING (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
);

ALTER TABLE subcategories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins have full access to subcategories"
ON subcategories
FOR ALL
TO authenticated
USING (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM auth.users WHERE id = auth.uid()) = 'super_admin'
);

-- Add public read access for published content
CREATE POLICY "Anyone can read published posts"
ON posts
FOR SELECT
TO public
USING (published = true);

CREATE POLICY "Anyone can read categories"
ON categories
FOR SELECT
TO public
USING (true);

CREATE POLICY "Anyone can read locations"
ON locations
FOR SELECT
TO public
USING (true);

CREATE POLICY "Anyone can read organizations"
ON organizations
FOR SELECT
TO public
USING (true);

CREATE POLICY "Anyone can read post categories"
ON post_categories
FOR SELECT
TO public
USING (true);

CREATE POLICY "Anyone can read post images"
ON post_images
FOR SELECT
TO public
USING (true);

CREATE POLICY "Anyone can read subcategories"
ON subcategories
FOR SELECT
TO public
USING (true);