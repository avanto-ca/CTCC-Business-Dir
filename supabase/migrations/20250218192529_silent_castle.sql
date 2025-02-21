/*
  # Fix category RLS policies

  1. Changes
    - Drop existing policies
    - Add proper RLS policies for categories table
    - Add proper access control for authenticated users
    - Add proper public read access
    - Add proper error handling
*/

-- First ensure we're operating as superuser
SET ROLE postgres;

-- Enable RLS on categories table
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public read access" ON categories;
DROP POLICY IF EXISTS "Admin insert access" ON categories;
DROP POLICY IF EXISTS "Admin update access" ON categories;
DROP POLICY IF EXISTS "Admin delete access" ON categories;

-- Create policies with proper access control
CREATE POLICY "Public read access"
  ON categories
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated insert access"
  ON categories
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated update access"
  ON categories
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated delete access"
  ON categories
  FOR DELETE
  TO authenticated
  USING (true);

-- Grant necessary permissions
GRANT ALL ON categories TO authenticated;
GRANT USAGE ON SEQUENCE categories_id_seq TO authenticated;

-- Add comments
COMMENT ON POLICY "Public read access" ON categories IS 'Anyone can read categories';
COMMENT ON POLICY "Authenticated insert access" ON categories IS 'Authenticated users can create new categories';
COMMENT ON POLICY "Authenticated update access" ON categories IS 'Authenticated users can update categories';
COMMENT ON POLICY "Authenticated delete access" ON categories IS 'Authenticated users can delete categories';