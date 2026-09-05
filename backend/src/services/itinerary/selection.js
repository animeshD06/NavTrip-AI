import { MAX_PLACES_PER_DAY } from './plannerConfig.js';
import { scorePlace } from './scoringEngine.js';

function byScoreThenRatingThenName(first, second) {
  return (
    second.score - first.score ||
    Number(second.place.rating || 0) - Number(first.place.rating || 0) ||
    first.place.name.localeCompare(second.place.name)
  );
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

function targetPlaceCount(places, input) {
  return Math.min(places.length, input.dayCount * MAX_PLACES_PER_DAY);
}

export function selectPlaces(candidates, input) {
  const available = dedupePlaces(candidates);
  const selected = [];
  const count = targetPlaceCount(available, input);

  while (selected.length < count) {
    const ranked = available
      .filter((place) => !selected.some((selectedPlace) => selectedPlace.id === place.id))
      .map((place) => ({
        place,
        score: scorePlace(place, input, selected),
      }))
      .sort(byScoreThenRatingThenName);

    if (!ranked.length) {
      break;
    }

    const next = ranked[0];
    selected.push({
      ...next.place,
      score: next.score,
    });
  }

  return selected;
}
