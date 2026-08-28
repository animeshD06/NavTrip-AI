CREATE EXTENSION IF NOT EXISTS postgis;

ALTER TABLE tourist_places
  ADD COLUMN IF NOT EXISTS geog GEOGRAPHY(Point, 4326);

UPDATE tourist_places
SET geog = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography
WHERE geog IS NULL;

CREATE INDEX IF NOT EXISTS idx_tourist_places_geog
  ON tourist_places
  USING GIST (geog);

CREATE OR REPLACE FUNCTION sync_tourist_places_geog()
RETURNS trigger AS $$
BEGIN
  NEW.geog = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_tourist_places_sync_geog ON tourist_places;

CREATE TRIGGER trg_tourist_places_sync_geog
BEFORE INSERT OR UPDATE OF latitude, longitude
ON tourist_places
FOR EACH ROW
EXECUTE FUNCTION sync_tourist_places_geog();
