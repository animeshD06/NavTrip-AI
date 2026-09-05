import { SCORING_WEIGHTS } from './plannerConfig.js';

const RELATED_CATEGORIES = {
  adventure: ['nature', 'family'],
  family: ['historical', 'nature', 'food'],
  food: ['family'],
  historical: ['religious', 'family'],
  nature: ['adventure', 'family'],
  religious: ['historical', 'family'],
};

function normalize(value) {
  return String(value || '').trim().toLowerCase();
}

function categoryMatchScore(placeCategory, selectedCategory) {
  const normalizedCategory = normalize(placeCategory);

  if (normalizedCategory === selectedCategory) {
    return 1;
  }

  if ((RELATED_CATEGORIES[selectedCategory] || []).includes(normalizedCategory)) {
    return 0.55;
  }

  return 0.2;
}

function interestOverlapScore(place, interests) {
  const placeSignals = new Set([
    normalize(place.category),
    ...normalize(place.name).split(/\s+/),
    ...normalize(place.description).split(/\W+/),
  ].filter(Boolean));

  if (!interests.length) {
    return 0;
  }

  const matches = interests.filter((interest) => placeSignals.has(interest));
  return matches.length / interests.length;
}

function travelStyleScore(place, travelStyle) {
  const category = normalize(place.category);

  if (travelStyle === 'relaxed') {
    return ['food', 'family', 'nature', 'religious'].includes(category) ? 1 : 0.75;
  }

  if (travelStyle === 'packed') {
    return ['historical', 'adventure', 'nature'].includes(category) ? 1 : 0.8;
  }

  return 0.9;
}

function budgetFitScore(place, budget, dayCount, groupSize) {
  if (budget === null) {
    return 0.8;
  }

  const roughPerStopCost = place.category === 'food' ? 450 : 250;
  const dailyBudget = budget / Math.max(1, dayCount);
  const stopBudget = dailyBudget / Math.max(1, groupSize);

  if (stopBudget >= roughPerStopCost * 3) return 1;
  if (stopBudget >= roughPerStopCost * 1.5) return 0.85;
  if (stopBudget >= roughPerStopCost) return 0.65;
  return 0.4;
}

function diversityScore(place, selectedPlaces) {
  if (!selectedPlaces.length) {
    return 1;
  }

  const sameCategoryCount = selectedPlaces.filter(
    (selected) => normalize(selected.category) === normalize(place.category),
  ).length;

  return Math.max(0.35, 1 - sameCategoryCount * 0.2);
}

export function scorePlace(place, input, selectedPlaces = []) {
  const ratingScore = Math.min(1, Math.max(0, Number(place.rating || 0) / 5));
  const score =
    SCORING_WEIGHTS.rating * ratingScore +
    SCORING_WEIGHTS.categoryMatch * categoryMatchScore(place.category, input.normalizedCategory) +
    SCORING_WEIGHTS.interestOverlap * interestOverlapScore(place, input.interests) +
    SCORING_WEIGHTS.travelStyleFit * travelStyleScore(place, input.travelStyle) +
    SCORING_WEIGHTS.budgetFit * budgetFitScore(place, input.budget, input.dayCount, input.groupSize) +
    SCORING_WEIGHTS.diversity * diversityScore(place, selectedPlaces);

  return Number(score.toFixed(4));
}
