-- Create site settings table
CREATE TABLE site_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_title text NOT NULL DEFAULT 'CTCC Business Directory',
  site_description text NOT NULL DEFAULT 'Find trusted Tamil professionals and businesses in your community',
  contact_email text NOT NULL DEFAULT 'admin@ctcc.ca',
  updated_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Allow public read access"
  ON site_settings
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow admin full access"
  ON site_settings
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Add trigger for updated_at
CREATE TRIGGER update_site_settings_updated_at
  BEFORE UPDATE ON site_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE site_settings IS 'Global site settings and configurations';
COMMENT ON COLUMN site_settings.site_title IS 'Main title used across the site';
COMMENT ON COLUMN site_settings.site_description IS 'Default meta description';
COMMENT ON COLUMN site_settings.contact_email IS 'Primary contact email for the site';