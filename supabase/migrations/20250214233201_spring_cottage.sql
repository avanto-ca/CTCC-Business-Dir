/*
  # Create members table

  1. New Tables
    - `members`
      - `id` (text, primary key)
      - `Name` (text)
      - `Firstname` (text)
      - `Lastname` (text)
      - `logo` (text)
      - `address` (text)
      - `type` (text)
      - `phone` (text)
      - `email` (text)
      - `website` (text)
      - `iframe` (text)
      - `aboutus` (text)
      - `sectionItem1` (text)
      - `sectionItem2` (text)
      - `sectionItem3` (text)
      - `created_at` (timestamp with time zone)

  2. Security
    - Enable RLS on `members` table
    - Add policy for authenticated users to read all members
*/

CREATE TABLE IF NOT EXISTS members (
  id text PRIMARY KEY,
  Name text,
  Firstname text,
  Lastname text,
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