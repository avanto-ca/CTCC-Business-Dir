/*
  # Update categories table to use UUID

  1. Changes
    - Add UUID primary key
    - Make name unique but not primary key
    - Update foreign key relationship
    
  2. Security
    - Maintain existing RLS policies
*/

-- Drop existing foreign key constraint
ALTER TABLE members DROP CONSTRAINT IF EXISTS fk_member_category;

-- Create new categories table with UUID
CREATE TABLE IF NOT EXISTS categories_new (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  icon text NOT NULL,
  url text UNIQUE NOT NULL,
  seo_tags text[],
  color text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE categories_new ENABLE ROW LEVEL SECURITY;

-- Add public read access policy
CREATE POLICY "Allow public read access"
  ON categories_new
  FOR SELECT
  TO public
  USING (true);

-- Insert existing categories
INSERT INTO categories_new (name, icon, url, seo_tags, color) VALUES
('Accountants', 'FileSpreadsheet', 'accountants', 
  ARRAY['accounting', 'tax', 'bookkeeping', 'financial services', 'CPA', 'tax planning'],
  'bg-blue-500'),
  
('Lawyers', 'Scale', 'lawyers',
  ARRAY['legal services', 'attorney', 'law firm', 'legal advice', 'litigation', 'corporate law'],
  'bg-red-500'),
  
('RealEstate', 'Home', 'real-estate',
  ARRAY['real estate', 'property', 'homes', 'housing', 'realty', 'real estate agent'],
  'bg-green-500'),
  
('Finance', 'Banknote', 'finance',
  ARRAY['financial services', 'investment', 'banking', 'wealth management', 'mortgage'],
  'bg-purple-500'),
  
('Entrepreneur', 'Briefcase', 'entrepreneur',
  ARRAY['business', 'startup', 'entrepreneurship', 'small business', 'innovation'],
  'bg-yellow-500'),
  
('Engineering', 'Wrench', 'engineering',
  ARRAY['engineering services', 'technical consulting', 'design', 'construction', 'project management'],
  'bg-indigo-500'),
  
('AutoServices', 'Car', 'auto-services',
  ARRAY['auto repair', 'car service', 'mechanic', 'vehicle maintenance', 'automotive'],
  'bg-orange-500'),
  
('Beauty', 'Scissors', 'beauty',
  ARRAY['beauty salon', 'hair styling', 'cosmetics', 'spa', 'personal care'],
  'bg-pink-500'),
  
('Restaurants', 'Utensils', 'restaurants',
  ARRAY['dining', 'food service', 'catering', 'restaurant', 'cuisine'],
  'bg-teal-500'),
  
('Education', 'GraduationCap', 'education',
  ARRAY['tutoring', 'teaching', 'training', 'education services', 'learning'],
  'bg-cyan-500'),
  
('HealthCare', 'Heart', 'healthcare',
  ARRAY['medical services', 'health', 'wellness', 'healthcare provider', 'clinic'],
  'bg-rose-500'),
  
('EventManagement', 'CalendarDays', 'event-management',
  ARRAY['events', 'planning', 'coordination', 'weddings', 'conferences'],
  'bg-emerald-500'),
  
('CleaningServices', 'Building2', 'cleaning-services',
  ARRAY['cleaning', 'janitorial', 'maintenance', 'commercial cleaning', 'residential cleaning'],
  'bg-sky-500'),
  
('Impex', 'Warehouse', 'impex',
  ARRAY['import', 'export', 'trade', 'international business', 'wholesale'],
  'bg-violet-500');

-- Add name_to_id mapping table for transition
CREATE TABLE category_mapping (
  name text PRIMARY KEY,
  category_id uuid REFERENCES categories_new(id)
);

-- Populate mapping table
INSERT INTO category_mapping (name, category_id)
SELECT name, id FROM categories_new;

-- Add category_id column to members
ALTER TABLE members ADD COLUMN category_id uuid;

-- Update members with new category IDs
UPDATE members 
SET category_id = cm.category_id
FROM category_mapping cm
WHERE members.type = cm.name;

-- Add foreign key constraint
ALTER TABLE members 
  ADD CONSTRAINT fk_member_category_id 
  FOREIGN KEY (category_id) 
  REFERENCES categories_new(id);

-- Drop old categories table
DROP TABLE IF EXISTS categories CASCADE;

-- Rename new table
ALTER TABLE categories_new RENAME TO categories;

-- Drop mapping table
DROP TABLE category_mapping;

-- Add comment
COMMENT ON TABLE categories IS 'Business categories with UUID primary key and metadata for SEO and display';