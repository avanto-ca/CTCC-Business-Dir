/*
  # Admin User Setup

  1. New Tables
    - `auth.users` - Ensures auth schema and users table exists
    - `user_roles` - Stores user roles (admin, member)
  
  2. Security
    - Enable RLS on all tables
    - Add policies for role-based access
    
  3. Data
    - Create admin user with secure password
    - Assign admin role
*/

-- Create auth schema if not exists
CREATE SCHEMA IF NOT EXISTS auth;

-- Create users table if not exists
CREATE TABLE IF NOT EXISTS auth.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE,
  encrypted_password text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create user_roles table if not exists
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'member')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Users can read own data"
  ON auth.users
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Users can read own role"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Create admin user
DO $$
DECLARE
  admin_uid uuid;
BEGIN
  -- Create admin user
  INSERT INTO auth.users (
    email,
    encrypted_password,
    created_at,
    updated_at
  )
  VALUES (
    'admin@ctcc.ca',
    crypt('CTCC2025Admin!', gen_salt('bf')),
    now(),
    now()
  )
  ON CONFLICT (email) DO UPDATE
  SET encrypted_password = crypt('CTCC2025Admin!', gen_salt('bf'))
  RETURNING id INTO admin_uid;

  -- Assign admin role
  INSERT INTO user_roles (user_id, role)
  VALUES (admin_uid, 'admin')
  ON CONFLICT (user_id) DO UPDATE
  SET role = 'admin';
END $$;