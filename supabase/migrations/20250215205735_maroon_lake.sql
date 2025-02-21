/*
  # Create categories table with metadata

  1. New Tables
    - `categories`
      - `name` (text, primary key) - Category name
      - `icon` (text) - Lucide icon name
      - `url` (text) - SEO-friendly URL slug
      - `seo_tags` (text[]) - Array of SEO keywords
      - `color` (text) - Tailwind color class
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on categories table
    - Add policy for public read access
*/

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  name text PRIMARY KEY,
  icon text NOT NULL,
  url text UNIQUE NOT NULL,
  seo_tags text[],
  color text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Add public read access policy
CREATE POLICY "Allow public read access"
  ON categories
  FOR SELECT
  TO public
  USING (true);

-- Insert existing categories
INSERT INTO categories (name, icon, url, seo_tags, color) VALUES
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

-- Add foreign key to members table
ALTER TABLE members ADD CONSTRAINT fk_member_category
  FOREIGN KEY (type) REFERENCES categories(name)
  ON UPDATE CASCADE;

-- Add comment
COMMENT ON TABLE categories IS 'Business categories with metadata for SEO and display';