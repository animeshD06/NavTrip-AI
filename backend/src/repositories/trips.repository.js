import { pool } from '../config/db.js';

function mapTrip(row) {
  return {
    id: row.id,
    userId: row.user_id,
    destination: row.destination,
    days: Number(row.days),
    category: row.category,
    budget: row.budget === null ? null : Number(row.budget),
    createdAt: row.created_at,
  };
}

function mapItineraryPlace(row) {
  return {
    placeId: row.place_id,
    name: row.name,
    category: row.category,
    sequenceOrder: Number(row.sequence_order),
    estimatedVisitMinutes: Number(row.estimated_visit_minutes),
    estimatedTravelMinutes:
      row.estimated_travel_minutes === null ? null : Number(row.estimated_travel_minutes),
    travelDistanceKm: row.travel_distance_km === null ? null : Number(row.travel_distance_km),
    openingTime: row.opening_time || '',
    closingTime: row.closing_time || '',
    latitude: Number(row.latitude),
    longitude: Number(row.longitude),
  };
}

function rowsToItinerary(trip, rows) {
  const daysByNumber = new Map();

  rows.forEach((row) => {
    const dayNumber = Number(row.day_number);

    if (!daysByNumber.has(dayNumber)) {
      daysByNumber.set(dayNumber, {
        dayNumber,
        places: [],
      });
    }

    daysByNumber.get(dayNumber).places.push(mapItineraryPlace(row));
  });

  return {
    tripId: trip.id,
    destination: trip.destination,
    days: Array.from(daysByNumber.values()).sort(
      (first, second) => first.dayNumber - second.dayNumber,
    ),
    totalPlaces: rows.length,
    generatedBy: 'rule-based-city-routing',
  };
}

export async function listTripsFromDatabase({ userId } = {}) {
  const values = [];
  const whereClause = userId ? 'WHERE user_id = $1' : 'WHERE user_id IS NULL';

  if (userId) {
    values.push(userId);
  }

  const result = await pool.query(
    `
      SELECT id, user_id, destination, days, category, budget, created_at
      FROM trips
      ${whereClause}
      ORDER BY created_at DESC
    `,
    values,
  );

  return result.rows.map(mapTrip);
}

export async function createTripInDatabase({
  destination,
  days,
  category,
  budget,
  itinerary,
  userId,
}) {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const tripResult = await client.query(
      `
        INSERT INTO trips (user_id, destination, days, category, budget)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, user_id, destination, days, category, budget, created_at
      `,
      [userId || null, destination, days, category, budget ?? null],
    );

    const trip = mapTrip(tripResult.rows[0]);

    for (const day of itinerary.days) {
      for (const place of day.places) {
        await client.query(
          `
            INSERT INTO itineraries (
              trip_id,
              day_number,
              place_id,
              sequence_order,
              estimated_visit_minutes,
              estimated_travel_minutes,
              travel_distance_km
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7)
          `,
          [
            trip.id,
            day.dayNumber,
            place.placeId,
            place.sequenceOrder,
            place.estimatedVisitMinutes,
            place.estimatedTravelMinutes ?? null,
            place.travelDistanceKm ?? 0,
          ],
        );
      }
    }

    await client.query('COMMIT');

    return {
      ...trip,
      itinerary: {
        tripId: trip.id,
        ...itinerary,
      },
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

export async function findTripByIdFromDatabase(id, { userId } = {}) {
  const values = [id];
  const userClause = userId ? 'AND user_id = $2' : 'AND user_id IS NULL';

  if (userId) {
    values.push(userId);
  }

  const tripResult = await pool.query(
    `
      SELECT id, user_id, destination, days, category, budget, created_at
      FROM trips
      WHERE id = $1
      ${userClause}
    `,
    values,
  );

  if (!tripResult.rows[0]) {
    return null;
  }

  const trip = mapTrip(tripResult.rows[0]);
  const itinerary = await findItineraryByTripIdFromDatabase(id, trip, { userId });

  return {
    ...trip,
    itinerary,
  };
}

export async function findItineraryByTripIdFromDatabase(
  tripId,
  existingTrip = null,
  { userId } = {},
) {
  const values = [tripId];
  const userClause = userId ? 'AND user_id = $2' : 'AND user_id IS NULL';

  if (userId) {
    values.push(userId);
  }

  const trip =
    existingTrip ||
    (
      await pool.query(
        `
          SELECT id, user_id, destination, days, category, budget, created_at
          FROM trips
          WHERE id = $1
          ${userClause}
        `,
        values,
      )
    ).rows[0];

  if (!trip) {
    return null;
  }

  const normalizedTrip = existingTrip || mapTrip(trip);
  const itineraryResult = await pool.query(
    `
      SELECT
        i.day_number,
        i.place_id,
        i.sequence_order,
        i.estimated_visit_minutes,
        i.estimated_travel_minutes,
        i.travel_distance_km,
        p.name,
        p.category,
        p.latitude,
        p.longitude,
        p.opening_time,
        p.closing_time
      FROM itineraries i
      JOIN tourist_places p ON p.id = i.place_id
      WHERE i.trip_id = $1
      ORDER BY i.day_number ASC, i.sequence_order ASC
    `,
    [tripId],
  );

  return rowsToItinerary(normalizedTrip, itineraryResult.rows);
}

export async function deleteTripFromDatabase(id, { userId } = {}) {
  const values = [id];
  const userClause = userId ? 'AND user_id = $2' : 'AND user_id IS NULL';

  if (userId) {
    values.push(userId);
  }

  const result = await pool.query(
    `DELETE FROM trips WHERE id = $1 ${userClause}`,
    values,
  );
  return result.rowCount > 0;
}
