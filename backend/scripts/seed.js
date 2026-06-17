import 'dotenv/config';

import { pool } from '../src/config/db.js';
import { touristPlaces } from '../src/data/tourist-places.js';

const upsertPlace = `
  INSERT INTO tourist_places (
    id,
    name,
    category,
    latitude,
    longitude,
    description,
    city,
    state,
    rating,
    opening_time,
    closing_time
  ) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
  )
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    category = EXCLUDED.category,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    description = EXCLUDED.description,
    city = EXCLUDED.city,
    state = EXCLUDED.state,
    rating = EXCLUDED.rating,
    opening_time = EXCLUDED.opening_time,
    closing_time = EXCLUDED.closing_time;
`;

try {
  for (const place of touristPlaces) {
    await pool.query(upsertPlace, [
      place.id,
      place.name,
      place.category,
      place.latitude,
      place.longitude,
      place.description,
      place.city,
      place.state,
      place.rating,
      place.openingTime,
      place.closingTime,
    ]);
  }

  console.log(`Database seed applied. Upserted ${touristPlaces.length} places.`);
} finally {
  await pool.end();
}
