-- Create super admin user
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
  'authenticated',
  'quirkautogroupmaine@gmail.com',
  crypt('QuirkAuto2024!', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"], "role": "super_admin"}',
  '{"role": "super_admin"}',
  now(),
  now(),
  '',
  '',
  '',
  ''
);

-- Add super admin role
CREATE POLICY "Super admins have full access"
ON posts
FOR ALL
TO authenticated
USING (
  auth.jwt() ->> 'role' = 'super_admin'
)
WITH CHECK (
  auth.jwt() ->> 'role' = 'super_admin'
);