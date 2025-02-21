/*
  # Add contact submissions table

  1. New Tables
    - `contact_submissions`
      - `id` (uuid, primary key)
      - `first_name` (text)
      - `last_name` (text)
      - `email` (text)
      - `phone` (text)
      - `message` (text)
      - `recipient_name` (text)
      - `recipient_email` (text)
      - `category` (text)
      - `business_url` (text)
      - `status` (text)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS
    - Add policy for public insert access
    - Add policy for authenticated users to read their own submissions
*/

-- Create contact submissions table
CREATE TABLE contact_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name text NOT NULL,
  last_name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  message text NOT NULL,
  recipient_name text NOT NULL,
  recipient_email text,
  category text,
  business_url text,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE contact_submissions ENABLE ROW LEVEL SECURITY;

-- Allow public insert access
CREATE POLICY "Allow insert access"
  ON contact_submissions
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Allow authenticated users to read their own submissions
CREATE POLICY "Allow read access to authenticated users"
  ON contact_submissions
  FOR SELECT
  TO authenticated
  USING (recipient_email = auth.email());

-- Add indexes for better query performance
CREATE INDEX idx_contact_submissions_recipient_email 
  ON contact_submissions(recipient_email);

CREATE INDEX idx_contact_submissions_created_at 
  ON contact_submissions(created_at DESC);

-- Add comments
COMMENT ON TABLE contact_submissions IS 'Stores contact form submissions from the business directory';
COMMENT ON COLUMN contact_submissions.status IS 'Status of the submission (pending, read, replied, etc.)';