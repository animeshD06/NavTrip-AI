CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tourist_places (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  description TEXT,
  city TEXT NOT NULL,
  state TEXT,
  rating NUMERIC(2, 1),
  opening_time TIME,
  closing_time TIME,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE tourist_places ADD COLUMN IF NOT EXISTS state TEXT;

CREATE INDEX IF NOT EXISTS idx_tourist_places_city ON tourist_places (city);
CREATE INDEX IF NOT EXISTS idx_tourist_places_state ON tourist_places (state);
CREATE INDEX IF NOT EXISTS idx_tourist_places_category ON tourist_places (category);
CREATE INDEX IF NOT EXISTS idx_tourist_places_coordinates ON tourist_places (latitude, longitude);

CREATE TABLE IF NOT EXISTS trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  destination TEXT NOT NULL,
  days INTEGER NOT NULL CHECK (days > 0),
  category TEXT NOT NULL,
  budget NUMERIC(12, 2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS itineraries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  day_number INTEGER NOT NULL CHECK (day_number > 0),
  place_id TEXT NOT NULL REFERENCES tourist_places(id) ON DELETE CASCADE,
  sequence_order INTEGER NOT NULL CHECK (sequence_order > 0),
  estimated_visit_minutes INTEGER NOT NULL DEFAULT 90,
  estimated_travel_minutes INTEGER,
  travel_distance_km NUMERIC(8, 2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (trip_id, day_number, sequence_order)
);
