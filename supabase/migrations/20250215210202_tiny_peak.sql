/*
  # Add Web Design category

  1. New Category
    - Add Web Design category with appropriate metadata
    - Include relevant SEO tags and description
    
  2. Security
    - Inherits existing RLS policies from categories table
*/

-- Insert Web Design category
INSERT INTO categories (
  name,
  icon,
  url,
  seo_tags,
  color,
  description
) VALUES (
  'WebDesign',
  'Code',
  'web-design',
  ARRAY[
    'web design',
    'web development',
    'website creation',
    'digital presence',
    'responsive design',
    'UI/UX',
    'web solutions'
  ],
  'bg-fuchsia-500',
  'Professional web design and development services creating modern, responsive websites. Expertise in user experience, custom development, and digital solutions for businesses.'
);