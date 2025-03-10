/*
  # Fix member ID column type

  1. Changes
    - Update members table to use integer primary key
    - Update foreign key references in seo_metadata table
    - Ensure data integrity during migration
*/

-- First, create a temporary table to store the mapping
CREATE TABLE temp_id_mapping (
  old_id text,
  new_id integer
);

-- Create sequence for new IDs
CREATE SEQUENCE IF NOT EXISTS members_id_seq;

-- Insert mappings
INSERT INTO temp_id_mapping (old_id, new_id)
SELECT id, nextval('members_id_seq')
FROM members;

-- Create new members table with correct ID type
CREATE TABLE members_new (
  id integer PRIMARY KEY DEFAULT nextval('members_id_seq'),
  "Name" text,
  "Firstname" text,
  "Lastname" text,
  logo text,
  address text,
  category_id uuid REFERENCES categories(id),
  phone text,
  email text,
  website text,
  iframe text,
  aboutus text,
  aboutus_html text,
  sectionItem1 text,
  sectionItem2 text,
  sectionItem3 text,
  created_at timestamptz DEFAULT now()
);

-- Copy data with new IDs
INSERT INTO members_new (
  id, "Name", "Firstname", "Lastname", logo, address, 
  category_id, phone, email, website, iframe, aboutus, 
  aboutus_html, sectionItem1, sectionItem2, sectionItem3, 
  created_at
)
SELECT 
  m2.new_id, m1."Name", m1."Firstname", m1."Lastname", 
  m1.logo, m1.address, m1.category_id, m1.phone, m1.email, 
  m1.website, m1.iframe, m1.aboutus, m1.aboutus_html, 
  m1.sectionItem1, m1.sectionItem2, m1.sectionItem3, 
  m1.created_at
FROM members m1
JOIN temp_id_mapping m2 ON m1.id = m2.old_id;

-- Update seo_metadata to use new integer IDs
ALTER TABLE seo_metadata 
  DROP CONSTRAINT seo_metadata_member_id_fkey;

UPDATE seo_metadata s
SET member_id = m.new_id::text
FROM temp_id_mapping m
WHERE s.member_id = m.old_id;

-- Drop old members table and rename new one
DROP TABLE members;
ALTER TABLE members_new RENAME TO members;

-- Update seo_metadata foreign key
ALTER TABLE seo_metadata
  ALTER COLUMN member_id TYPE integer USING member_id::integer,
  ADD CONSTRAINT seo_metadata_member_id_fkey 
    FOREIGN KEY (member_id) 
    REFERENCES members(id)
    ON DELETE CASCADE;

-- Clean up
DROP TABLE temp_id_mapping;

-- Re-enable RLS
ALTER TABLE members ENABLE ROW LEVEL SECURITY;

-- Recreate RLS policies
CREATE POLICY "Allow public read access"
  ON members
  FOR SELECT
  TO public
  USING (true);

-- Add comments
COMMENT ON TABLE members IS 'Member profiles with integer primary key';
COMMENT ON COLUMN members.id IS 'Auto-incrementing integer primary key';