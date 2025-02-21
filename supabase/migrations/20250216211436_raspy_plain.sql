/*
  # Add user roles and admin access control

  1. New Tables
    - `user_roles` - Stores user roles and permissions
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `role` (text)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on user_roles table
    - Add policies for role-based access
    - Add function to check admin status
*/

-- Create user roles table
CREATE TABLE user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'member')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Allow users to read their own role"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Allow admins to manage roles"
  ON user_roles
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Create function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid()
    AND role = 'admin'
  );
$$;

-- Update existing RLS policies to check for admin role
ALTER POLICY "Allow authenticated users to update their own metadata"
  ON seo_metadata
  USING (
    member_id IN (
      SELECT id FROM members 
      WHERE email = auth.email()
    )
    OR is_admin()
  )
  WITH CHECK (
    member_id IN (
      SELECT id FROM members 
      WHERE email = auth.email()
    )
    OR is_admin()
  );

-- Add admin-only policies for listings and promotions
ALTER POLICY "Allow public read access"
  ON realtor_listings
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow admins to manage listings"
  ON realtor_listings
  FOR ALL
  TO authenticated
  USING (is_admin());

ALTER POLICY "Allow public read access"
  ON promotions
  FOR SELECT
  TO public
  USING (
    active = true AND
    start_date <= CURRENT_TIMESTAMP AND
    end_date >= CURRENT_TIMESTAMP
  );

CREATE POLICY "Allow admins to manage promotions"
  ON promotions
  FOR ALL
  TO authenticated
  USING (is_admin());

-- Add indexes
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);

-- Add comments
COMMENT ON TABLE user_roles IS 'Stores user roles for access control';
COMMENT ON COLUMN user_roles.role IS 'User role (admin or member)';