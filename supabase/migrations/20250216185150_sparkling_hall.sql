/*
  # Fix SEO metadata foreign key constraint

  1. Changes
    - Drop existing seo_metadata table if it exists
    - Recreate seo_metadata table with correct column types
    - Add RLS policies and indexes
    - Add update trigger for updated_at
*/

-- Drop existing table if it exists
DROP TABLE IF EXISTS seo_metadata;

-- Create SEO metadata table with correct column types
CREATE TABLE seo_metadata (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id text REFERENCES members(id) ON DELETE CASCADE,
  title text,
  description text,
  keywords text[],
  og_title text,
  og_description text,
  twitter_title text,
  twitter_description text,
  schema_description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(member_id)
);

-- Enable RLS
ALTER TABLE seo_metadata ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Allow public read access"
  ON seo_metadata
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to update their own metadata"
  ON seo_metadata
  FOR UPDATE
  TO authenticated
  USING (
    member_id IN (
      SELECT id FROM members 
      WHERE email = auth.email()
    )
  )
  WITH CHECK (
    member_id IN (
      SELECT id FROM members 
      WHERE email = auth.email()
    )
  );

-- Add function to update timestamp if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
    CREATE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
      NEW.updated_at = now();
      RETURN NEW;
    END;
    $$ language 'plpgsql';
  END IF;
END $$;

-- Add trigger for updating timestamp
DROP TRIGGER IF EXISTS update_seo_metadata_updated_at ON seo_metadata;
CREATE TRIGGER update_seo_metadata_updated_at
  BEFORE UPDATE
  ON seo_metadata
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add indexes for better performance
CREATE INDEX idx_seo_metadata_member_id ON seo_metadata(member_id);
CREATE INDEX idx_seo_metadata_updated_at ON seo_metadata(updated_at DESC);

-- Add comments
COMMENT ON TABLE seo_metadata IS 'Stores SEO metadata for member profiles';
COMMENT ON COLUMN seo_metadata.title IS 'Custom SEO title override';
COMMENT ON COLUMN seo_metadata.description IS 'Custom meta description override';
COMMENT ON COLUMN seo_metadata.keywords IS 'Array of SEO keywords specific to this member';
COMMENT ON COLUMN seo_metadata.schema_description IS 'Custom description for Schema.org markup';