import { haversineDistanceKm } from '../../utils/distance.js';

function routeDistance(places) {
  return places.reduce((sum, place, index) => {
    const previousPlace = places[index - 1];

    if (!previousPlace) {
      return sum;
    }

    return sum + haversineDistanceKm(
      previousPlace.latitude,
      previousPlace.longitude,
      place.latitude,
      place.longitude,
    );
  }, 0);
}

function nearestNeighbor(places) {
  const [start, ...rest] = [...places].sort(
    (first, second) => second.score - first.score || first.name.localeCompare(second.name),
  );

  if (!start) {
    return [];
  }

  const ordered = [start];
  const remaining = rest;

  while (remaining.length) {
    const current = ordered[ordered.length - 1];
    let nearestIndex = 0;
    let nearestScore = Number.POSITIVE_INFINITY;

    remaining.forEach((place, index) => {
      const distance = haversineDistanceKm(
        current.latitude,
        current.longitude,
        place.latitude,
        place.longitude,
      );
      const ratingPenalty = Math.max(0, 5 - Number(place.rating || 0)) * 0.15;
      const scorePenalty = Math.max(0, 1 - Number(place.score || 0)) * 0.2;
      const routeScore = distance + ratingPenalty + scorePenalty;

      if (routeScore < nearestScore) {
        nearestScore = routeScore;
        nearestIndex = index;
      }
    });

    ordered.push(remaining.splice(nearestIndex, 1)[0]);
  }

  return ordered;
}

function twoOpt(places) {
  if (places.length < 4) {
    return places;
  }

  let bestRoute = places;
  let improved = true;

  while (improved) {
    improved = false;

    for (let firstIndex = 1; firstIndex < bestRoute.length - 2; firstIndex += 1) {
      for (let secondIndex = firstIndex + 1; secondIndex < bestRoute.length - 1; secondIndex += 1) {
        const candidate = [
          ...bestRoute.slice(0, firstIndex),
          ...bestRoute.slice(firstIndex, secondIndex + 1).reverse(),
          ...bestRoute.slice(secondIndex + 1),
        ];

        if (routeDistance(candidate) < routeDistance(bestRoute)) {
          bestRoute = candidate;
          improved = true;
        }
      }
    }
  }

  return bestRoute;
}

export function routeDayPlaces(days) {
  return days.map((day) => ({
    dayNumber: day.dayNumber,
    places: twoOpt(nearestNeighbor(day.places)),
  }));
}
