/*
  # Add realtor member relation

  1. Changes
    - Add foreign key constraint to realtor_profiles table
    - Add index for member_id lookup
    - Add example data for Gobi Thiru

  2. Security
    - Maintain existing RLS policies
*/

-- Add foreign key constraint
ALTER TABLE realtor_profiles
  ADD CONSTRAINT fk_realtor_profiles_member
  FOREIGN KEY (member_id)
  REFERENCES members(id)
  ON DELETE CASCADE;

-- Add index for member lookup
CREATE INDEX IF NOT EXISTS idx_realtor_profiles_member_id
  ON realtor_profiles(member_id);

-- Insert example data for Gobi Thiru
INSERT INTO realtor_profiles (member_id, realtor_id, realtor_url)
SELECT 
  m.id,
  '2011015',
  'https://www.realtor.ca/agent/2011015/'
FROM members m
WHERE m."Firstname" = 'Gobiraj' 
  AND m."Lastname" = 'Thiruchelvam'
ON CONFLICT (realtor_id) DO NOTHING;