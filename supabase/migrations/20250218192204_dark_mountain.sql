/*
  # Fix category RLS policies

  1. Changes
    - Drop existing policies
    - Add proper RLS policies for categories table
    - Add proper access control for authenticated users
    - Add proper public read access
*/

-- First ensure we're operating as superuser
SET ROLE postgres;

-- Enable RLS on categories table
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public read access" ON categories;
DROP POLICY IF EXISTS "Admin manage access" ON categories;
DROP POLICY IF EXISTS "Allow public read access" ON categories;
DROP POLICY IF EXISTS "Allow admin full access" ON categories;

-- Create policies with proper access control
CREATE POLICY "Public read access"
  ON categories
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admin insert access"
  ON categories
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Admin update access"
  ON categories
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Admin delete access"
  ON categories
  FOR DELETE
  TO authenticated
  USING (true);

-- Add comments
COMMENT ON POLICY "Public read access" ON categories IS 'Anyone can read categories';
COMMENT ON POLICY "Admin insert access" ON categories IS 'Authenticated users can create new categories';
COMMENT ON POLICY "Admin update access" ON categories IS 'Authenticated users can update categories';
COMMENT ON POLICY "Admin delete access" ON categories IS 'Authenticated users can delete categories';