-- ================================================================
-- LENS & FRAME – Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ================================================================

-- 1. PROFILES table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT,
  phone       TEXT,
  role        TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'admin')),
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. BOOKINGS table
CREATE TABLE IF NOT EXISTS public.bookings (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service_id                TEXT NOT NULL,
  service_name              TEXT NOT NULL,
  event_date                DATE NOT NULL,
  event_time                TEXT,
  location                  TEXT,
  notes                     TEXT,
  client_name               TEXT,
  client_phone              TEXT,
  total_price               INTEGER NOT NULL,    -- in cents
  deposit_amount            INTEGER NOT NULL,    -- in cents
  status                    TEXT NOT NULL DEFAULT 'pending'
                              CHECK (status IN ('pending','confirmed','cancelled','completed')),
  payment_status            TEXT NOT NULL DEFAULT 'pending'
                              CHECK (payment_status IN ('pending','deposit_paid','paid','refunded')),
  stripe_payment_intent_id  TEXT,
  created_at                TIMESTAMPTZ DEFAULT NOW(),
  updated_at                TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Auto-create profile on signup trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, phone)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'phone'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Auto-update updated_at on bookings
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS bookings_updated_at ON public.bookings;
CREATE TRIGGER bookings_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ================================================================
-- ROW LEVEL SECURITY (RLS) — IMPORTANT: enables data protection
-- ================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings  ENABLE ROW LEVEL SECURITY;

-- Profiles: users see/edit only their own
CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Bookings: users see/edit only their own
CREATE POLICY "bookings_select_own" ON public.bookings
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "bookings_insert_own" ON public.bookings
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "bookings_update_own" ON public.bookings
  FOR UPDATE USING (auth.uid() = user_id);

-- Admin: full access via role check
CREATE POLICY "admin_all_profiles" ON public.profiles
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );
CREATE POLICY "admin_all_bookings" ON public.bookings
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ================================================================
-- MAKE YOURSELF ADMIN
-- After signing up, run this with your user's UUID:
-- UPDATE public.profiles SET role = 'admin' WHERE id = 'YOUR_USER_UUID';
-- ================================================================
