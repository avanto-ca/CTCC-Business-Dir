/*
  # Create contact submissions table

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
      - `created_at` (timestamptz)
      - `status` (text)

  2. Security
    - Enable RLS
    - Add policy for authenticated users to read their own submissions
*/

CREATE TABLE contact_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name text NOT NULL,
  last_name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  message text NOT NULL,
  recipient_name text NOT NULL,
  recipient_email text NOT NULL,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE contact_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow insert access"
  ON contact_submissions
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Allow read access to authenticated users"
  ON contact_submissions
  FOR SELECT
  TO authenticated
  USING (recipient_email = auth.email());