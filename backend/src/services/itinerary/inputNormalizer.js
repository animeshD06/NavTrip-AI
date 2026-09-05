const DEFAULT_TRAVEL_STYLE = 'balanced';
const DEFAULT_GROUP_SIZE = 1;

const TRAVEL_STYLE_ALIASES = {
  balanced: 'balanced',
  moderate: 'balanced',
  relaxed: 'relaxed',
  slow: 'relaxed',
  packed: 'packed',
  busy: 'packed',
};

function normalizeText(value) {
  return String(value || '').trim();
}

function normalizeInterestList(interests, category) {
  const rawInterests = Array.isArray(interests) ? interests : [];
  const normalized = rawInterests
    .map((interest) => normalizeText(interest).toLowerCase())
    .filter(Boolean);
  const categoryInterest = normalizeText(category).toLowerCase();

  return Array.from(new Set([categoryInterest, ...normalized].filter(Boolean)));
}

function normalizeTravelStyle(travelStyle) {
  const normalized = normalizeText(travelStyle).toLowerCase();
  return TRAVEL_STYLE_ALIASES[normalized] || DEFAULT_TRAVEL_STYLE;
}

function normalizeGroupSize(groupSize) {
  const parsed = Number(groupSize);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    return DEFAULT_GROUP_SIZE;
  }

  return Math.min(parsed, 20);
}

function normalizeBudget(budget) {
  const parsed = Number(budget);

  if (!Number.isFinite(parsed) || parsed < 0) {
    return null;
  }

  return parsed;
}

export function normalizeItineraryInput({
  destination,
  days,
  category,
  interests,
  travelStyle,
  groupSize,
  budget,
}) {
  const dayCount = Math.max(1, Number(days) || 1);
  const normalizedCategory = normalizeText(category).toLowerCase();

  return {
    destination: normalizeText(destination),
    dayCount,
    category: normalizeText(category),
    normalizedCategory,
    interests: normalizeInterestList(interests, category),
    travelStyle: normalizeTravelStyle(travelStyle),
    groupSize: normalizeGroupSize(groupSize),
    budget: normalizeBudget(budget),
  };
}
