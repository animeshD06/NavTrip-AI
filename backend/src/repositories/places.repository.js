import { pool } from '../config/db.js';

function mapPlace(row) {
  return {
    id: row.id,
    name: row.name,
    category: row.category,
    latitude: Number(row.latitude),
    longitude: Number(row.longitude),
    description: row.description || '',
    city: row.city,
    state: row.state || '',
    rating: Number(row.rating || 0),
    openingTime: row.opening_time || '',
    closingTime: row.closing_time || '',
    distanceKm: row.distance_km === undefined ? undefined : Number(row.distance_km),
  };
}

export async function listPlacesFromDatabase({ city, state, category, search } = {}) {
  const conditions = [];
  const values = [];

  if (city) {
    values.push(city);
    conditions.push(`LOWER(city) = LOWER($${values.length})`);
  }

  if (state) {
    values.push(state);
    conditions.push(`LOWER(state) = LOWER($${values.length})`);
  }

  if (category) {
    values.push(category);
    conditions.push(`LOWER(category) = LOWER($${values.length})`);
  }

  if (search) {
    values.push(`%${search}%`);
    conditions.push(`name ILIKE $${values.length}`);
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await pool.query(
    `
      SELECT
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
      FROM tourist_places
      ${whereClause}
      ORDER BY rating DESC NULLS LAST, name ASC
    `,
    values,
  );

  return result.rows.map(mapPlace);
}

export async function findPlaceByIdFromDatabase(id) {
  const result = await pool.query(
    `
      SELECT
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
      FROM tourist_places
      WHERE id = $1
    `,
    [id],
  );

  return result.rows[0] ? mapPlace(result.rows[0]) : null;
}

export async function listNearbyPlacesFromDatabase({
  latitude,
  longitude,
  radiusKm,
  category,
}) {
  const values = [latitude, longitude, radiusKm];
  const distanceExpression = `
    6371 * 2 * ASIN(SQRT(
      POWER(SIN(RADIANS(latitude - $1) / 2), 2) +
      COS(RADIANS($1)) * COS(RADIANS(latitude)) *
      POWER(SIN(RADIANS(longitude - $2) / 2), 2)
    ))
  `;
  const conditions = [`${distanceExpression} <= $3`];

  if (category) {
    values.push(category);
    conditions.push(`LOWER(category) = LOWER($${values.length})`);
  }

  const result = await pool.query(
    `
      SELECT
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
        closing_time,
        ROUND((${distanceExpression})::numeric, 2) AS distance_km
      FROM tourist_places
      WHERE ${conditions.join(' AND ')}
      ORDER BY distance_km ASC
    `,
    values,
  );

  return result.rows.map(mapPlace);
}
