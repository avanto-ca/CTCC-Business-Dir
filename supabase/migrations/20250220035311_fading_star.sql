/*
  # Add business leads functionality
  
  1. New Tables
    - `business_leads`
      - `id` (uuid, primary key)
      - `name` (text, business/owner name)
      - `email` (text, contact email)
      - `phone` (text, contact phone)
      - `business_type` (text, type of business)
      - `message` (text, additional details)
      - `status` (text, lead status)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      
  2. Security
    - Enable RLS
    - Public can submit leads
    - Only admins can view/manage leads
*/

-- Create business leads table
CREATE TABLE business_leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  business_type text NOT NULL,
  message text,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'contacted', 'approved', 'rejected')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE business_leads ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow public to submit leads"
  ON business_leads
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Allow admins to manage leads"
  ON business_leads
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
CREATE TRIGGER update_business_leads_updated_at
  BEFORE UPDATE ON business_leads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add indexes
CREATE INDEX idx_business_leads_status ON business_leads(status);
CREATE INDEX idx_business_leads_created_at ON business_leads(created_at DESC);

-- Add comments
COMMENT ON TABLE business_leads IS 'Stores business listing requests';
COMMENT ON COLUMN business_leads.status IS 'Status of the lead (pending, contacted, approved, rejected)';