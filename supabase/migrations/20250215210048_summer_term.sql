/*
  # Add category descriptions

  1. Changes
    - Add description column to categories table
    - Update existing categories with descriptions
    
  2. Security
    - Maintain existing RLS policies
*/

-- Add description column
ALTER TABLE categories ADD COLUMN description text;

-- Update existing categories with descriptions
UPDATE categories SET description = CASE
  WHEN name = 'Accountants' THEN
    'Professional accounting services including tax preparation, financial planning, and business advisory. Our accountants help individuals and businesses manage their finances effectively.'
    
  WHEN name = 'Lawyers' THEN
    'Legal professionals providing comprehensive services in corporate law, family law, real estate, immigration, and more. Expert legal advice and representation.'
    
  WHEN name = 'RealEstate' THEN
    'Real estate professionals helping clients buy, sell, and invest in properties. Expertise in residential and commercial real estate, property management, and market analysis.'
    
  WHEN name = 'Finance' THEN
    'Financial services including investment management, mortgage solutions, retirement planning, and wealth management. Helping clients achieve their financial goals.'
    
  WHEN name = 'Entrepreneur' THEN
    'Business leaders and innovators offering various services from consulting to startup incubation. Supporting business growth and development.'
    
  WHEN name = 'Engineering' THEN
    'Engineering services spanning civil, mechanical, electrical, and software domains. Professional solutions for technical challenges and project management.'
    
  WHEN name = 'AutoServices' THEN
    'Automotive services including repairs, maintenance, and specialized care for all types of vehicles. Professional mechanics and automotive experts.'
    
  WHEN name = 'Beauty' THEN
    'Beauty and wellness services including hair styling, skincare, spa treatments, and cosmetic services. Professional care for personal beauty needs.'
    
  WHEN name = 'Restaurants' THEN
    'Dining establishments offering various cuisines, catering services, and food delivery. Quality food and exceptional dining experiences.'
    
  WHEN name = 'Education' THEN
    'Educational services including tutoring, professional training, and skills development. Supporting learning and academic achievement.'
    
  WHEN name = 'HealthCare' THEN
    'Healthcare services providing medical care, wellness programs, and health consultations. Professional care for your health and well-being.'
    
  WHEN name = 'EventManagement' THEN
    'Event planning and management services for corporate events, weddings, and special occasions. Creating memorable experiences.'
    
  WHEN name = 'CleaningServices' THEN
    'Professional cleaning services for residential and commercial properties. Maintaining clean and healthy environments.'
    
  WHEN name = 'Impex' THEN
    'Import and export services facilitating international trade. Expertise in global commerce and supply chain management.'
END;