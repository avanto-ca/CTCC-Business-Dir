/*
  # Add promotions table

  1. New Tables
    - `promotions`
      - `id` (uuid, primary key)
      - `member_id` (integer, foreign key to members)
      - `title` (text)
      - `description` (text)
      - `image_url` (text)
      - `start_date` (timestamptz)
      - `end_date` (timestamptz)
      - `active` (boolean)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS
    - Add policy for public read access
*/

-- Create promotions table
CREATE TABLE promotions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id integer REFERENCES members(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  image_url text,
  start_date timestamptz NOT NULL,
  end_date timestamptz NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_date_range CHECK (end_date > start_date)
);

-- Enable RLS
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Allow public read access"
  ON promotions
  FOR SELECT
  TO public
  USING (
    active = true AND
    start_date <= CURRENT_TIMESTAMP AND
    end_date >= CURRENT_TIMESTAMP
  );

-- Add indexes
CREATE INDEX idx_promotions_member_id ON promotions(member_id);
CREATE INDEX idx_promotions_active_dates ON promotions(active, start_date, end_date);

-- Add comments
COMMENT ON TABLE promotions IS 'Stores promotional content for member profiles';
COMMENT ON COLUMN promotions.title IS 'Title of the promotion';
COMMENT ON COLUMN promotions.description IS 'Optional description text';
COMMENT ON COLUMN promotions.image_url IS 'URL to the promotional image';
COMMENT ON COLUMN promotions.start_date IS 'When the promotion starts';
COMMENT ON COLUMN promotions.end_date IS 'When the promotion ends';
COMMENT ON COLUMN promotions.active IS 'Whether the promotion is currently active';