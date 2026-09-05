import crypto from 'node:crypto';

import { hasDatabaseConfig } from '../config/db.js';
import {
  createTripInDatabase,
  deleteTripFromDatabase,
  findItineraryByTripIdFromDatabase,
  findTripByIdFromDatabase,
  listTripsFromDatabase,
} from '../repositories/trips.repository.js';
import { buildItinerary } from './itineraries.service.js';

const trips = [];
const itinerariesByTripId = new Map();

export async function listTrips({ userId } = {}) {
  if (hasDatabaseConfig()) {
    return listTripsFromDatabase({ userId });
  }

  return trips.filter((trip) => trip.userId === (userId || null));
}

export async function createTripWithItinerary({
  destination,
  days,
  category,
  budget,
  interests,
  travelStyle,
  groupSize,
  userId,
}) {
  const itinerary = await buildItinerary({
    destination,
    days,
    category,
    budget,
    interests,
    travelStyle,
    groupSize,
  });

  if (hasDatabaseConfig()) {
    return createTripInDatabase({
      destination,
      days: Number(days),
      category,
      budget,
      itinerary,
      userId,
    });
  }

  const trip = {
    id: crypto.randomUUID(),
    userId: userId || null,
    destination,
    days: Number(days),
    category,
    budget: budget ?? null,
    createdAt: new Date().toISOString(),
  };

  const savedItinerary = {
    tripId: trip.id,
    ...itinerary,
  };

  trips.push(trip);
  itinerariesByTripId.set(trip.id, savedItinerary);

  return {
    ...trip,
    itinerary: savedItinerary,
  };
}

export async function findTripById(id, { userId } = {}) {
  if (hasDatabaseConfig()) {
    return findTripByIdFromDatabase(id, { userId });
  }

  const trip = trips.find((item) => item.id === id);

  if (!trip || trip.userId !== (userId || null)) {
    return null;
  }

  return {
    ...trip,
    itinerary: itinerariesByTripId.get(id),
  };
}

export async function findItineraryByTripId(tripId, { userId } = {}) {
  if (hasDatabaseConfig()) {
    return findItineraryByTripIdFromDatabase(tripId, null, { userId });
  }

  const trip = trips.find((item) => item.id === tripId);

  if (!trip || trip.userId !== (userId || null)) {
    return null;
  }

  return itinerariesByTripId.get(tripId) || null;
}

export async function removeTrip(id, { userId } = {}) {
  if (hasDatabaseConfig()) {
    return deleteTripFromDatabase(id, { userId });
  }

  const index = trips.findIndex(
    (trip) => trip.id === id && trip.userId === (userId || null),
  );

  if (index === -1) {
    return false;
  }

  trips.splice(index, 1);
  itinerariesByTripId.delete(id);

  return true;
}
