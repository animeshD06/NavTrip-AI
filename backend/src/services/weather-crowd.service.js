import { findNearbyPlaces, findPlaces } from './places.service.js';

function weatherSummary(city) {
  return {
    city,
    provider: 'local-estimate',
    summary: 'Mild travel conditions expected. Carry water and check live weather before long outdoor walks.',
    temperatureC: 28,
    rainProbability: 20,
    observedAt: new Date().toISOString(),
  };
}

function crowdLevel(place, hour) {
  const peak = hour >= 10 && hour <= 16;
  const popular = place.rating >= 4.5;

  if (peak && popular) {
    return { level: 'high', score: 82 };
  }

  if (peak || popular) {
    return { level: 'medium', score: 55 };
  }

  return { level: 'low', score: 28 };
}

export async function getWeatherCrowdInsights({ city, latitude, longitude }) {
  const places = latitude !== null && longitude !== null
    ? await findNearbyPlaces({ latitude, longitude, radiusKm: 20 })
    : await findPlaces({ city });
  const hour = new Date().getHours();

  return {
    weather: weatherSummary(city || places[0]?.city || 'current area'),
    alerts: [
      {
        type: 'rain',
        severity: 'low',
        message: 'No major rain risk in the local estimate.',
      },
    ],
    bestVisitingHours: ['08:00-10:00', '16:00-18:00'],
    crowdPredictions: places.slice(0, 10).map((place) => {
      const crowd = crowdLevel(place, hour);
      return {
        placeId: place.id,
        name: place.name,
        crowdLevel: crowd.level,
        score: crowd.score,
        recommendation: crowd.level === 'high'
          ? 'Visit early morning or late afternoon.'
          : 'Good time window available today.',
      };
    }),
  };
}
