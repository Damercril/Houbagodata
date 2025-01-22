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

-- Drop existing tables
DROP TABLE IF EXISTS public.affiliates CASCADE;
DROP TABLE IF EXISTS public.sponsors CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.admins CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.withdrawals CASCADE;
DROP TABLE IF EXISTS public.support_requests CASCADE;
DROP TABLE IF EXISTS public.migrations CASCADE;
DROP TABLE IF EXISTS public.courses CASCADE;
DROP TABLE IF EXISTS public.moto_partners CASCADE;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create admins table
CREATE TABLE public.admins (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name text NOT NULL,
  last_name text NOT NULL,
  phone text UNIQUE NOT NULL,
  pin text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Insert test admin
INSERT INTO public.admins (first_name, last_name, phone, pin) VALUES 
  ('Houbago', 'Admin', '+225 0652262798', '0909')
ON CONFLICT (phone) DO UPDATE SET 
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  pin = EXCLUDED.pin,
  updated_at = timezone('utc'::text, now());

-- Create users table
CREATE TABLE public.users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name text,
  last_name text,
  phone text NOT NULL UNIQUE,
  pin text NOT NULL DEFAULT '1111',
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS and add policies for users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Policy to allow public registration
CREATE POLICY "Allow public registration"
ON public.users
FOR INSERT
WITH CHECK (true);

-- Policy for users to view their own profile
CREATE POLICY "Users can view own profile"
ON public.users
FOR SELECT
USING (
  auth.uid() = id 
  OR EXISTS (
    SELECT 1 FROM public.admins
    WHERE admins.id = auth.uid()
    AND admins.pin = '0909'
  )
);

-- Policy for admins to view all users
CREATE POLICY "Admins can view all users"
ON public.users
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.admins
    WHERE admins.id = auth.uid()
  )
);

-- Policy for users to update their own profile
CREATE POLICY "Users can update own profile"
ON public.users
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Create affiliates table
CREATE TABLE public.affiliates (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name text NOT NULL,
  last_name text NOT NULL,
  phone text NOT NULL UNIQUE,
  photo_url text,
  id_card_url text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for affiliates table
ALTER TABLE public.affiliates ENABLE ROW LEVEL SECURITY;

-- Policy to allow public registration for affiliates
CREATE POLICY "Allow public registration for affiliates"
ON public.affiliates
FOR INSERT
TO public
WITH CHECK (true);

-- Policy to allow public read for affiliates
CREATE POLICY "Allow public read for affiliates"
ON public.affiliates
FOR SELECT
TO public
USING (true);

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  type text NOT NULL,
  title text NOT NULL,
  message text NOT NULL,
  user_id uuid REFERENCES public.users,
  data jsonb,
  read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create withdrawals table
CREATE TABLE IF NOT EXISTS public.withdrawals (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.users NOT NULL,
  amount numeric NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create support requests table
CREATE TABLE IF NOT EXISTS public.support_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.users NOT NULL,
  subject text NOT NULL,
  message text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  audio_url text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create course_partners table
CREATE TABLE public.course_partners (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create moto_partners table
CREATE TABLE public.moto_partners (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Insert default partners
DELETE FROM public.course_partners;
DELETE FROM public.moto_partners;

INSERT INTO public.course_partners (name) 
VALUES ('SAGT')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.moto_partners (name) 
VALUES ('Agbocorp')
ON CONFLICT (name) DO NOTHING;

-- Enable RLS for partners tables
ALTER TABLE public.course_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moto_partners ENABLE ROW LEVEL SECURITY;

-- Allow public read access to partners tables
CREATE POLICY "Allow public read access to course_partners"
ON public.course_partners
FOR SELECT
USING (true);

CREATE POLICY "Allow public read access to moto_partners"
ON public.moto_partners
FOR SELECT
USING (true);

-- Add foreign keys to users table
ALTER TABLE public.users 
ADD COLUMN course_partner_id uuid REFERENCES public.course_partners(id),
ADD COLUMN moto_partner_id uuid REFERENCES public.moto_partners(id);

-- Create migrations table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.migrations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  executed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create function to handle migrations
CREATE OR REPLACE FUNCTION handle_migrations()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  migration_name text;
BEGIN
  -- List of migrations
  FOR migration_name IN (
    SELECT m.name 
    FROM (VALUES
      ('001_initial_schema'),
      ('002_add_users_table'),
      ('003_add_affiliates_table'),
      ('004_add_admins_table'),
      ('005_add_notifications_table'),
      ('006_add_withdrawals_table'),
      ('007_add_support_requests_table')
    ) AS m(name)
    WHERE NOT EXISTS (
      SELECT 1 FROM migrations WHERE name = m.name
    )
    ORDER BY m.name
  )
  LOOP
    RAISE NOTICE 'Executing migration: %', migration_name;
    
    -- Execute migration based on name
    CASE migration_name
      WHEN '001_initial_schema' THEN
        -- Enable UUID extension
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        
      WHEN '002_add_users_table' THEN
        -- Create users table
        CREATE TABLE IF NOT EXISTS public.users (
          id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
          first_name text NOT NULL,
          last_name text NOT NULL,
          phone text NOT NULL UNIQUE,
          created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
          updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
        );
        
      WHEN '003_add_affiliates_table' THEN
        -- Create affiliates table
        CREATE TABLE IF NOT EXISTS public.affiliates (
          id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
          user_id uuid REFERENCES public.users(id) NOT NULL,
          first_name text NOT NULL,
          last_name text NOT NULL,
          phone text NOT NULL,
          status text NOT NULL DEFAULT 'pending',
          driver_type text NOT NULL,
          photo_identity_url text,
          photo_license_url text,
          created_at timestamp with time zone DEFAULT now(),
          updated_at timestamp with time zone DEFAULT now()
        );
        
      WHEN '004_add_admins_table' THEN
        -- Create admins table
        CREATE TABLE IF NOT EXISTS public.admins (
          id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
          first_name text NOT NULL,
          last_name text NOT NULL,
          phone text UNIQUE NOT NULL,
          pin text NOT NULL,
          created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
          updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
        );
        
      WHEN '005_add_notifications_table' THEN
        -- Create notifications table
        CREATE TABLE IF NOT EXISTS public.notifications (
          id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
          type text NOT NULL,
          title text NOT NULL,
          message text NOT NULL,
          user_id uuid REFERENCES public.users,
          data jsonb,
          read boolean DEFAULT false,
          created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
        );
        
      WHEN '006_add_withdrawals_table' THEN
        -- Create withdrawals table
        CREATE TABLE IF NOT EXISTS public.withdrawals (
          id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
          user_id uuid REFERENCES public.users NOT NULL,
          amount numeric NOT NULL,
          status text NOT NULL DEFAULT 'pending',
          created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
          updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
        );
        
      WHEN '007_add_support_requests_table' THEN
        -- Create support requests table
        CREATE TABLE IF NOT EXISTS public.support_requests (
          id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
          user_id uuid REFERENCES public.users NOT NULL,
          subject text NOT NULL,
          message text NOT NULL,
          status text NOT NULL DEFAULT 'pending',
          audio_url text,
          created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
          updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
        );
        
    END CASE;
    
    -- Record migration
    INSERT INTO migrations (name) VALUES (migration_name);
    RAISE NOTICE 'Migration completed: %', migration_name;
  END LOOP;
END;
$$;

-- Run migrations
SELECT handle_migrations();
