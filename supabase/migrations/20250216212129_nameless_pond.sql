-- Create admin user if it doesn't exist
DO $$
DECLARE
  admin_uid uuid;
BEGIN
  -- Insert admin user if not exists
  INSERT INTO auth.users (
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role
  )
  VALUES (
    'admin@ctcc.ca',
    crypt('CTCC2025Admin!', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"name":"CTCC Admin"}',
    'authenticated',
    'authenticated'
  )
  ON CONFLICT (email) DO NOTHING
  RETURNING id INTO admin_uid;

  -- Assign admin role
  IF admin_uid IS NOT NULL THEN
    INSERT INTO user_roles (user_id, role)
    VALUES (admin_uid, 'admin')
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
END $$;

-- Add comment
COMMENT ON TABLE user_roles IS 'Stores user roles including the default admin account';