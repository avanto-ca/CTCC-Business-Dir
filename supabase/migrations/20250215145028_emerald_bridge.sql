/*
  # Create members table with proper column casing

  1. New Tables
    - `members`
      - `id` (text, primary key)
      - `name` (text, nullable)
      - `firstname` (text, nullable)
      - `lastname` (text, nullable)
      - `logo` (text, nullable)
      - `address` (text, nullable)
      - `type` (text, nullable)
      - `phone` (text, nullable)
      - `email` (text, nullable)
      - `website` (text, nullable)
      - `iframe` (text, nullable)
      - `aboutus` (text, nullable)
      - `sectionItem1` (text, nullable)
      - `sectionItem2` (text, nullable)
      - `sectionItem3` (text, nullable)
      - `created_at` (timestamptz, default: now())

  2. Security
    - Enable RLS on `members` table
    - Add policy for public read access
*/

CREATE TABLE IF NOT EXISTS members (
  id text PRIMARY KEY,
  name text,
  firstname text,
  lastname text,
  logo text,
  address text,
  type text,
  phone text,
  email text,
  website text,
  iframe text,
  aboutus text,
  sectionItem1 text,
  sectionItem2 text,
  sectionItem3 text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access"
  ON members
  FOR SELECT
  TO public
  USING (true);