import { findNearbyPlaces, findPlaces } from './places.service.js';

function matchesQuery(place, query) {
  const text = `${place.name} ${place.category} ${place.city} ${place.state} ${place.description}`.toLowerCase();
  return query
    .toLowerCase()
    .split(/\s+/)
    .filter(Boolean)
    .some((word) => text.includes(word));
}

function buildAnswer(query, results) {
  if (!results.length) {
    return {
      answer: 'I could not find a matching cached place. Try a city name, attraction name, food, nature, or nearby query.',
      confidence: 0.25,
    };
  }

  const top = results[0];

  if (/eat|food|restaurant/i.test(query)) {
    return {
      answer: `For food nearby, start with ${top.name} in ${top.city}. It is tagged as ${top.category} and has a ${top.rating.toFixed(1)} rating.`,
      confidence: 0.78,
    };
  }

  if (/nearby|visit/i.test(query)) {
    return {
      answer: `A good nearby option is ${top.name}. ${top.description}`,
      confidence: 0.82,
    };
  }

  return {
    answer: `${top.name}: ${top.description}`,
    confidence: 0.8,
  };
}

export async function answerAssistantQuery({
  query,
  city,
  latitude,
  longitude,
  offlinePreferred = true,
}) {
  const places = latitude !== null && longitude !== null
    ? await findNearbyPlaces({ latitude, longitude, radiusKm: 25 })
    : await findPlaces({ city });
  const directMatches = places.filter((place) => matchesQuery(place, query));
  const results = directMatches.length ? directMatches : places.slice(0, 5);
  const answer = buildAnswer(query, results);

  return {
    ...answer,
    mode: offlinePreferred ? 'offline-local-search' : 'online-local-first',
    sources: results.slice(0, 5).map((place) => ({
      placeId: place.id,
      name: place.name,
      category: place.category,
      city: place.city,
      distanceKm: place.distanceKm,
    })),
  };
}
