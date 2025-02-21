/*
  # Add realtor listings integration

  1. New Tables
    - `realtor_profiles`
      - `id` (uuid, primary key)
      - `member_id` (integer, foreign key to members)
      - `realtor_id` (text, unique)
      - `realtor_url` (text)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

    - `realtor_listings`
      - `id` (uuid, primary key)
      - `realtor_profile_id` (uuid, foreign key)
      - `mls_number` (text)
      - `address` (text)
      - `price` (numeric)
      - `bedrooms` (integer)
      - `bathrooms` (numeric)
      - `description` (text)
      - `photos` (text[])
      - `listing_url` (text)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS
    - Add policies for public read access
*/

-- Create realtor profiles table
CREATE TABLE realtor_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id integer REFERENCES members(id) ON DELETE CASCADE,
  realtor_id text UNIQUE NOT NULL,
  realtor_url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create realtor listings table
CREATE TABLE realtor_listings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  realtor_profile_id uuid REFERENCES realtor_profiles(id) ON DELETE CASCADE,
  mls_number text NOT NULL,
  address text NOT NULL,
  price numeric NOT NULL,
  bedrooms integer,
  bathrooms numeric,
  description text,
  photos text[],
  listing_url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(realtor_profile_id, mls_number)
);

-- Enable RLS
ALTER TABLE realtor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE realtor_listings ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Allow public read access"
  ON realtor_profiles
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public read access"
  ON realtor_listings
  FOR SELECT
  TO public
  USING (true);

-- Add indexes
CREATE INDEX idx_realtor_profiles_member_id ON realtor_profiles(member_id);
CREATE INDEX idx_realtor_listings_profile_id ON realtor_listings(realtor_profile_id);
CREATE INDEX idx_realtor_listings_price ON realtor_listings(price DESC);

-- Add update trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers
CREATE TRIGGER update_realtor_profiles_updated_at
  BEFORE UPDATE ON realtor_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_realtor_listings_updated_at
  BEFORE UPDATE ON realtor_listings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE realtor_profiles IS 'Stores realtor.ca profile information for real estate agents';
COMMENT ON TABLE realtor_listings IS 'Stores property listings from realtor.ca';