/*
  # Create Categories Table with Complete Data

  1. New Table
    - Create categories table with UUID primary key
    - Add all metadata columns (icon, URL, SEO tags, color, description)
    - Include timestamps
    
  2. Security
    - Enable Row Level Security (RLS)
    - Add public read access policy
    
  3. Data
    - Insert all category data with complete metadata
    - Include descriptions and SEO tags for each category
*/

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  icon text NOT NULL,
  url text UNIQUE NOT NULL,
  seo_tags text[],
  color text NOT NULL,
  description text,
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

-- Insert all categories with complete metadata
INSERT INTO categories (name, icon, url, seo_tags, color, description) VALUES
('Accountants', 'FileSpreadsheet', 'accountants', 
  ARRAY['accounting', 'tax', 'bookkeeping', 'financial services', 'CPA', 'tax planning'],
  'bg-blue-500',
  'Professional accounting services including tax preparation, financial planning, and business advisory. Our accountants help individuals and businesses manage their finances effectively.'),
  
('Lawyers', 'Scale', 'lawyers',
  ARRAY['legal services', 'attorney', 'law firm', 'legal advice', 'litigation', 'corporate law'],
  'bg-red-500',
  'Legal professionals providing comprehensive services in corporate law, family law, real estate, immigration, and more. Expert legal advice and representation.'),
  
('RealEstate', 'Home', 'real-estate',
  ARRAY['real estate', 'property', 'homes', 'housing', 'realty', 'real estate agent'],
  'bg-green-500',
  'Real estate professionals helping clients buy, sell, and invest in properties. Expertise in residential and commercial real estate, property management, and market analysis.'),
  
('Finance', 'Banknote', 'finance',
  ARRAY['financial services', 'investment', 'banking', 'wealth management', 'mortgage'],
  'bg-purple-500',
  'Financial services including investment management, mortgage solutions, retirement planning, and wealth management. Helping clients achieve their financial goals.'),
  
('Entrepreneur', 'Briefcase', 'entrepreneur',
  ARRAY['business', 'startup', 'entrepreneurship', 'small business', 'innovation'],
  'bg-yellow-500',
  'Business leaders and innovators offering various services from consulting to startup incubation. Supporting business growth and development.'),
  
('Engineering', 'Wrench', 'engineering',
  ARRAY['engineering services', 'technical consulting', 'design', 'construction', 'project management'],
  'bg-indigo-500',
  'Engineering services spanning civil, mechanical, electrical, and software domains. Professional solutions for technical challenges and project management.'),
  
('AutoServices', 'Car', 'auto-services',
  ARRAY['auto repair', 'car service', 'mechanic', 'vehicle maintenance', 'automotive'],
  'bg-orange-500',
  'Automotive services including repairs, maintenance, and specialized care for all types of vehicles. Professional mechanics and automotive experts.'),
  
('Beauty', 'Scissors', 'beauty',
  ARRAY['beauty salon', 'hair styling', 'cosmetics', 'spa', 'personal care'],
  'bg-pink-500',
  'Beauty and wellness services including hair styling, skincare, spa treatments, and cosmetic services. Professional care for personal beauty needs.'),
  
('Restaurants', 'Utensils', 'restaurants',
  ARRAY['dining', 'food service', 'catering', 'restaurant', 'cuisine'],
  'bg-teal-500',
  'Dining establishments offering various cuisines, catering services, and food delivery. Quality food and exceptional dining experiences.'),
  
('Education', 'GraduationCap', 'education',
  ARRAY['tutoring', 'teaching', 'training', 'education services', 'learning'],
  'bg-cyan-500',
  'Educational services including tutoring, professional training, and skills development. Supporting learning and academic achievement.'),
  
('HealthCare', 'Heart', 'healthcare',
  ARRAY['medical services', 'health', 'wellness', 'healthcare provider', 'clinic'],
  'bg-rose-500',
  'Healthcare services providing medical care, wellness programs, and health consultations. Professional care for your health and well-being.'),
  
('EventManagement', 'CalendarDays', 'event-management',
  ARRAY['events', 'planning', 'coordination', 'weddings', 'conferences'],
  'bg-emerald-500',
  'Event planning and management services for corporate events, weddings, and special occasions. Creating memorable experiences.'),
  
('CleaningServices', 'Building2', 'cleaning-services',
  ARRAY['cleaning', 'janitorial', 'maintenance', 'commercial cleaning', 'residential cleaning'],
  'bg-sky-500',
  'Professional cleaning services for residential and commercial properties. Maintaining clean and healthy environments.'),
  
('Impex', 'Warehouse', 'impex',
  ARRAY['import', 'export', 'trade', 'international business', 'wholesale'],
  'bg-violet-500',
  'Import and export services facilitating international trade. Expertise in global commerce and supply chain management.'),

('WebDesign', 'Code', 'web-design',
  ARRAY['web design', 'web development', 'website creation', 'digital presence', 'responsive design', 'UI/UX', 'web solutions'],
  'bg-fuchsia-500',
  'Professional web design and development services creating modern, responsive websites. Expertise in user experience, custom development, and digital solutions for businesses.');

-- Add foreign key to members table
ALTER TABLE members ADD COLUMN IF NOT EXISTS category_id uuid;

-- Update members with category IDs
UPDATE members 
SET category_id = c.id
FROM categories c
WHERE members.type = c.name;

-- Add foreign key constraint
ALTER TABLE members 
  ADD CONSTRAINT fk_member_category_id 
  FOREIGN KEY (category_id) 
  REFERENCES categories(id);

-- Add comments
COMMENT ON TABLE categories IS 'Business categories with UUID primary key and metadata for SEO and display';
COMMENT ON COLUMN categories.seo_tags IS 'Array of SEO keywords for improved discoverability';
COMMENT ON COLUMN categories.description IS 'Detailed description of the category and its services';