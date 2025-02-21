/*
  # Add sample community members

  1. New Data
    - Sample community members for various categories
    - Each member has basic contact information
    - References existing categories

  2. Security
    - Maintains existing RLS policies
    - Public read access
    - Admin-only write access
*/

-- Insert sample community members
INSERT INTO community_members (
  name,
  email,
  phone,
  category_id
) VALUES
-- Accountants
(
  'John Smith',
  'john.smith@email.com',
  '416-555-0101',
  (SELECT id FROM categories WHERE name = 'Accountants' LIMIT 1)
),
(
  'Mary Johnson',
  'mary.j@email.com',
  '647-555-0102',
  (SELECT id FROM categories WHERE name = 'Accountants' LIMIT 1)
),

-- Real Estate
(
  'David Brown',
  'david.brown@email.com',
  '416-555-0103',
  (SELECT id FROM categories WHERE name = 'RealEstate' LIMIT 1)
),
(
  'Sarah Wilson',
  'sarah.w@email.com',
  '647-555-0104',
  (SELECT id FROM categories WHERE name = 'RealEstate' LIMIT 1)
),

-- Finance
(
  'Michael Lee',
  'michael.lee@email.com',
  '416-555-0105',
  (SELECT id FROM categories WHERE name = 'Finance' LIMIT 1)
),
(
  'Jennifer Chen',
  'jennifer.c@email.com',
  '647-555-0106',
  (SELECT id FROM categories WHERE name = 'Finance' LIMIT 1)
),

-- Lawyers
(
  'Robert Taylor',
  'robert.t@email.com',
  '416-555-0107',
  (SELECT id FROM categories WHERE name = 'Lawyers' LIMIT 1)
),
(
  'Patricia Martinez',
  'patricia.m@email.com',
  '647-555-0108',
  (SELECT id FROM categories WHERE name = 'Lawyers' LIMIT 1)
),

-- Healthcare
(
  'William Anderson',
  'william.a@email.com',
  '416-555-0109',
  (SELECT id FROM categories WHERE name = 'HealthCare' LIMIT 1)
),
(
  'Elizabeth Thomas',
  'elizabeth.t@email.com',
  '647-555-0110',
  (SELECT id FROM categories WHERE name = 'HealthCare' LIMIT 1)
);

-- Add index for better search performance
CREATE INDEX IF NOT EXISTS idx_community_members_search 
ON community_members USING gin(
  to_tsvector('english',
    coalesce(name, '') || ' ' ||
    coalesce(email, '') || ' ' ||
    coalesce(phone, '')
  )
);

-- Add comments
COMMENT ON TABLE community_members IS 'Community members directory with basic contact information';