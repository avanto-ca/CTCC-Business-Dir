/*
  # Fix RLS policies and add user roles

  1. Changes
    - Fix RLS policy syntax
    - Add proper user role management
    - Add admin-specific policies
    - Add indexes for performance

  2. Security
    - Enable RLS on all tables
    - Add proper policies for public and authenticated access
    - Add admin role checks
*/

-- Create user roles table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'member')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to recreate them properly
DROP POLICY IF EXISTS "Allow public read access" ON members;
DROP POLICY IF EXISTS "Allow public read access" ON categories;
DROP POLICY IF EXISTS "Allow public read access" ON realtor_profiles;
DROP POLICY IF EXISTS "Allow public read access" ON realtor_listings;
DROP POLICY IF EXISTS "Allow public read access" ON promotions;
DROP POLICY IF EXISTS "Allow public read access" ON seo_metadata;

-- Add proper RLS policies
CREATE POLICY "Public read access for members"
  ON members FOR SELECT TO public
  USING (true);

CREATE POLICY "Public read access for categories"
  ON categories FOR SELECT TO public
  USING (true);

CREATE POLICY "Public read access for realtor profiles"
  ON realtor_profiles FOR SELECT TO public
  USING (true);

CREATE POLICY "Public read access for active listings"
  ON realtor_listings FOR SELECT TO public
  USING (true);

CREATE POLICY "Public read access for active promotions"
  ON promotions FOR SELECT TO public
  USING (
    active = true 
    AND start_date <= CURRENT_TIMESTAMP 
    AND end_date >= CURRENT_TIMESTAMP
  );

CREATE POLICY "Public read access for SEO metadata"
  ON seo_metadata FOR SELECT TO public
  USING (true);

-- Add admin-only policies
CREATE POLICY "Admin full access for members"
  ON members FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Admin full access for realtor profiles"
  ON realtor_profiles FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Admin full access for realtor listings"
  ON realtor_listings FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Admin full access for promotions"
  ON promotions FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Admin full access for SEO metadata"
  ON seo_metadata FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON user_roles(role);
CREATE INDEX IF NOT EXISTS idx_promotions_active_dates ON promotions(active, start_date, end_date);

-- Add comments
COMMENT ON TABLE user_roles IS 'Stores user roles for access control';
COMMENT ON COLUMN user_roles.role IS 'User role (admin or member)';
COMMENT ON COLUMN user_roles.user_id IS 'References auth.users(id) for role assignment';