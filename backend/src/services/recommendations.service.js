import { findNearbyPlaces, findPlaces } from './places.service.js';

function scorePlace(place, interests = []) {
  const interestMatch = interests.some(
    (interest) => place.category.toLowerCase() === String(interest).toLowerCase(),
  );
  const ratingScore = place.rating * 12;
  const hiddenGemBoost = place.rating >= 4.4 ? 20 : 8;
  const crowdPenalty = place.category === 'historical' ? 4 : 0;
  const distanceBoost = place.distanceKm === undefined
    ? 0
    : Math.max(0, 20 - place.distanceKm);

  return ratingScore + hiddenGemBoost + distanceBoost + (interestMatch ? 18 : 0) - crowdPenalty;
}

function reasonLabels(place, interests = []) {
  const labels = ['hidden gem'];

  if (place.rating >= 4.5) {
    labels.push('local favorite');
  }

  if (place.distanceKm !== undefined && place.distanceKm <= 5) {
    labels.push('near you');
  }

  if (interests.some((interest) => place.category.toLowerCase() === String(interest).toLowerCase())) {
    labels.push('matches interests');
  }

  if (place.category !== 'historical') {
    labels.push('less crowded');
  }

  return labels;
}

export async function getHiddenGemRecommendations({
  city,
  latitude,
  longitude,
  interests = [],
  includeVisited = false,
  visitedPlaceIds = [],
  limit = 10,
}) {
  const places = latitude !== null && longitude !== null
    ? await findNearbyPlaces({ latitude, longitude, radiusKm: 50 })
    : await findPlaces({ city });
  const visited = new Set(visitedPlaceIds);

  return places
    .filter((place) => includeVisited || !visited.has(place.id))
    .map((place) => ({
      place,
      score: Number(scorePlace(place, interests).toFixed(2)),
      reasons: reasonLabels(place, interests),
      explanation: `${place.name} is recommended because it is ${reasonLabels(place, interests).join(', ')}.`,
    }))
    .sort((first, second) => second.score - first.score)
    .slice(0, limit);
}
