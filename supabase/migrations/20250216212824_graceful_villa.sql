-- Create admin user with proper password hashing
DO $$
DECLARE
  admin_uid uuid;
BEGIN
  -- Insert admin user if not exists
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  )
  VALUES (
    '00000000-0000-0000-0000-000000000000',
    uuid_generate_v4(),
    'authenticated',
    'authenticated',
    'admin@ctcc.ca',
    crypt('CTCC2025Admin!', gen_salt('bf')),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "CTCC Admin"}',
    NOW(),
    NOW()
  )
  ON CONFLICT (email) DO NOTHING
  RETURNING id INTO admin_uid;

  -- Assign admin role if user was created
  IF admin_uid IS NOT NULL THEN
    INSERT INTO user_roles (user_id, role)
    VALUES (admin_uid, 'admin')
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
END $$;