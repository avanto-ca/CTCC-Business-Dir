/*
  # Add community members table

  1. New Tables
    - `community_members`
      - `id` (uuid, primary key)
      - `name` (text)
      - `email` (text)
      - `phone` (text)
      - `category_id` (uuid, references categories)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `community_members` table
    - Add policy for public read access
    - Add policy for admin management
*/

-- Create community members table
CREATE TABLE community_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text,
  phone text,
  category_id uuid NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public read access"
  ON community_members
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admin insert access"
  ON community_members
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Admin update access"
  ON community_members
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Admin delete access"
  ON community_members
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Add indexes
CREATE INDEX idx_community_members_category ON community_members(category_id);
CREATE INDEX idx_community_members_name ON community_members(name);

-- Add trigger for updated_at
CREATE TRIGGER update_community_members_updated_at
  BEFORE UPDATE ON community_members
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE community_members IS 'Stores community member profiles';
COMMENT ON COLUMN community_members.name IS 'Full name of the community member';
COMMENT ON COLUMN community_members.email IS 'Contact email address';
COMMENT ON COLUMN community_members.phone IS 'Contact phone number';
COMMENT ON COLUMN community_members.category_id IS 'References categories(id) for business category';