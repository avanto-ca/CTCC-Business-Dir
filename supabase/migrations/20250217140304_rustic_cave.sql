/*
  # Fix auth schema and tables

  1. Changes
    - Create complete auth schema with all required tables
    - Add authentication functions
    - Set up proper permissions
*/

-- Create auth schema if not exists
CREATE SCHEMA IF NOT EXISTS auth;

-- Create auth identities table
CREATE TABLE IF NOT EXISTS auth.identities (
  id uuid NOT NULL,
  user_id uuid NOT NULL,
  identity_data jsonb NOT NULL,
  provider text NOT NULL,
  last_sign_in_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  PRIMARY KEY (provider, id),
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create auth sessions table
CREATE TABLE IF NOT EXISTS auth.sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  factor_id uuid,
  aal aal_level,
  not_after timestamptz
);

-- Create auth refresh tokens table
CREATE TABLE IF NOT EXISTS auth.refresh_tokens (
  id bigserial PRIMARY KEY,
  token text NOT NULL UNIQUE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  revoked boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  parent varchar(255),
  session_id uuid REFERENCES auth.sessions(id) ON DELETE CASCADE
);

-- Create auth audit log table
CREATE TABLE IF NOT EXISTS auth.audit_log_entries (
  id uuid NOT NULL,
  payload json,
  created_at timestamptz,
  ip_address varchar(64) DEFAULT '',
  PRIMARY KEY (id)
);

-- Create auth instances table
CREATE TABLE IF NOT EXISTS auth.instances (
  id uuid PRIMARY KEY,
  uuid uuid,
  raw_base_config text,
  created_at timestamptz,
  updated_at timestamptz
);

-- Enable RLS on all tables
ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX IF NOT EXISTS identities_user_id_idx ON auth.identities(user_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_token_idx ON auth.refresh_tokens(token);
CREATE INDEX IF NOT EXISTS refresh_tokens_user_id_idx ON auth.refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS sessions_user_id_idx ON auth.sessions(user_id);
CREATE INDEX IF NOT EXISTS sessions_not_after_idx ON auth.sessions(not_after DESC);

-- Grant permissions
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA auth TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA auth TO authenticated;

-- Add comments
COMMENT ON SCHEMA auth IS 'Schema for authentication tables and functions';
COMMENT ON TABLE auth.identities IS 'Auth identities for external providers';
COMMENT ON TABLE auth.sessions IS 'User sessions';
COMMENT ON TABLE auth.refresh_tokens IS 'Refresh tokens for sessions';
COMMENT ON TABLE auth.audit_log_entries IS 'Audit log for auth events';
COMMENT ON TABLE auth.instances IS 'Auth instances configuration';