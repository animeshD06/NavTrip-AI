import { findPlaces } from './places.service.js';
import { haversineDistanceKm } from '../utils/distance.js';
import { httpError } from '../utils/http.js';

const AVERAGE_CITY_SPEED_KMH = 25;
const STOP_BUFFER_MINUTES = 10;
const MIN_PLACES_PER_DAY = 2;
const MAX_PLACES_PER_DAY = 3;

const VISIT_MINUTES_BY_CATEGORY = {
  adventure: 120,
  family: 90,
  food: 75,
  historical: 90,
  nature: 120,
  religious: 75,
};

function normalize(value) {
  return String(value || '').trim().toLowerCase();
}

function byRatingThenName(first, second) {
  if (second.rating !== first.rating) {
    return second.rating - first.rating;
  }

  return first.name.localeCompare(second.name);
}

function dedupePlaces(places) {
  const seen = new Set();

  return places.filter((place) => {
    if (seen.has(place.id)) {
      return false;
    }

    seen.add(place.id);
    return true;
  });
}

function estimateVisitMinutes(category) {
  return VISIT_MINUTES_BY_CATEGORY[normalize(category)] || 90;
}

function orderPlacesByProximity(places) {
  const [start, ...rest] = places;

  if (!start) {
    return [];
  }

  const ordered = [start];
  const remaining = rest;

  while (remaining.length) {
    const current = ordered[ordered.length - 1];
    let nearestIndex = 0;
    let nearestDistance = Number.POSITIVE_INFINITY;

    remaining.forEach((place, index) => {
      const distance = haversineDistanceKm(
        current.latitude,
        current.longitude,
        place.latitude,
        place.longitude,
      );

      const ratingPenalty = Math.max(0, 5 - place.rating) * 0.15;
      const score = distance + ratingPenalty;

      if (score < nearestDistance) {
        nearestDistance = score;
        nearestIndex = index;
      }
    });

    ordered.push(remaining.splice(nearestIndex, 1)[0]);
  }

  return ordered;
}

function estimateTravelMinutes(distanceKm) {
  if (distanceKm === 0) {
    return 0;
  }

  return Math.max(
    5,
    Math.round((distanceKm / AVERAGE_CITY_SPEED_KMH) * 60 + STOP_BUFFER_MINUTES),
  );
}

function selectPlacesForTrip(allPlaces, category, dayCount) {
  const normalizedCategory = normalize(category);
  const sortedPlaces = [...allPlaces].sort(byRatingThenName);
  const preferredPlaces = sortedPlaces.filter(
    (place) => normalize(place.category) === normalizedCategory,
  );
  const complementaryPlaces = sortedPlaces.filter(
    (place) => normalize(place.category) !== normalizedCategory,
  );
  const targetCount = Math.min(
    sortedPlaces.length,
    Math.max(preferredPlaces.length, dayCount * MIN_PLACES_PER_DAY),
    dayCount * MAX_PLACES_PER_DAY,
  );

  return dedupePlaces([...preferredPlaces, ...complementaryPlaces])
    .slice(0, targetCount);
}

function splitIntoDays(orderedPlaces, dayCount) {
  const planDays = Array.from({ length: dayCount }, (_, index) => ({
    dayNumber: index + 1,
    places: [],
  }));

  if (!orderedPlaces.length) {
    return planDays;
  }

  const activeDayCount = Math.min(dayCount, orderedPlaces.length);
  const baseSize = Math.floor(orderedPlaces.length / activeDayCount);
  const extraDays = orderedPlaces.length % activeDayCount;
  let cursor = 0;

  for (let index = 0; index < activeDayCount; index += 1) {
    const chunkSize = baseSize + (index < extraDays ? 1 : 0);
    planDays[index].places = orderedPlaces.slice(cursor, cursor + chunkSize);
    cursor += chunkSize;
  }

  return planDays;
}

function buildDayPlaces(places) {
  return places.map((place, index) => {
    const previousPlace = places[index - 1];
    const travelDistanceKm = previousPlace
      ? haversineDistanceKm(
          previousPlace.latitude,
          previousPlace.longitude,
          place.latitude,
          place.longitude,
        )
      : 0;

    return {
      placeId: place.id,
      name: place.name,
      category: place.category,
      sequenceOrder: index + 1,
      estimatedVisitMinutes: estimateVisitMinutes(place.category),
      estimatedTravelMinutes: estimateTravelMinutes(travelDistanceKm),
      travelDistanceKm: Number(travelDistanceKm.toFixed(2)),
      openingTime: place.openingTime,
      closingTime: place.closingTime,
      latitude: place.latitude,
      longitude: place.longitude,
    };
  });
}

async function findDestinationPlaces(destination) {
  const cityPlaces = await findPlaces({ city: destination });

  if (cityPlaces.length) {
    return {
      places: cityPlaces,
      destinationType: 'city',
      resolvedDestination: cityPlaces[0].city,
      state: cityPlaces[0].state,
    };
  }

  const statePlaces = await findPlaces({ state: destination });

  if (statePlaces.length) {
    return {
      places: statePlaces,
      destinationType: 'state',
      resolvedDestination: statePlaces[0].state,
      state: statePlaces[0].state,
    };
  }

  throw httpError(404, 'NotFound', `No tourist places found for ${destination}`);
}

export async function buildItinerary({ destination, days, category }) {
  const dayCount = Math.max(1, Number(days) || 1);
  const destinationPlaces = await findDestinationPlaces(destination);
  const selectedPlaces = selectPlacesForTrip(
    destinationPlaces.places,
    category,
    dayCount,
  );
  const orderedPlaces = orderPlacesByProximity(selectedPlaces);
  const planDays = splitIntoDays(orderedPlaces, dayCount).map((day) => ({
    dayNumber: day.dayNumber,
    places: buildDayPlaces(day.places),
  }));

  return {
    destination: destinationPlaces.resolvedDestination || destination,
    destinationType: destinationPlaces.destinationType,
    state: destinationPlaces.state,
    categoryPreference: category,
    days: planDays,
    totalPlaces: orderedPlaces.length,
    generatedBy: 'rule-based-city-routing',
  };
}
