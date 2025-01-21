-- Create function to get table information
CREATE OR REPLACE FUNCTION get_table_info(table_name text)
RETURNS TABLE (
  column_name text,
  data_type text,
  is_nullable text,
  column_default text
) 
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
  FROM information_schema.columns 
  WHERE table_name = $1
  ORDER BY ordinal_position;
$$;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Disable RLS temporarily
ALTER TABLE IF EXISTS users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS earnings DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS notifications DISABLE ROW LEVEL SECURITY;

-- Drop existing tables if they exist (in correct order)
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS earnings CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Table des utilisateurs
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  pin TEXT NOT NULL,
  balance DOUBLE PRECISION DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table des gains quotidiens
CREATE TABLE earnings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  amount DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table des notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('earning', 'withdrawal', 'affiliation', 'system')),
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users" ON users 
  FOR SELECT USING (true);

CREATE POLICY "Enable insert access for all users" ON users 
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable read access for own earnings" ON earnings 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Enable insert access for own earnings" ON earnings 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable read access for own notifications" ON notifications 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Enable insert access for own notifications" ON notifications 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Insert test user
INSERT INTO users (first_name, last_name, phone, pin, balance)
VALUES ('John', 'Doe', '+225 0123456789', '1234', 0.0);

-- Insert test earnings
INSERT INTO earnings (user_id, amount, created_at)
SELECT 
  id as user_id,
  random() * 50000 as amount,
  CURRENT_TIMESTAMP - (n || ' days')::INTERVAL as created_at
FROM users
CROSS JOIN generate_series(0, 6) n
WHERE phone = '+225 0123456789';

-- Insert test notifications
INSERT INTO notifications (user_id, title, message, type, read, created_at)
SELECT 
  id as user_id,
  'Nouveau gain' as title,
  'Vous avez reçu ' || (random() * 50000)::INTEGER || ' FCFA' as message,
  'earning' as type,
  false as read,
  CURRENT_TIMESTAMP - (n || ' days')::INTERVAL as created_at
FROM users
CROSS JOIN generate_series(0, 2) n
WHERE phone = '+225 0123456789';
