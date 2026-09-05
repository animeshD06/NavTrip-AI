export const AVERAGE_CITY_SPEED_KMH = 25;
export const STOP_BUFFER_MINUTES = 10;
export const MIN_PLACES_PER_DAY = 2;
export const MAX_PLACES_PER_DAY = 3;
export const CLUSTER_RADIUS_KM = 3;

export const VISIT_MINUTES_BY_CATEGORY = {
  adventure: 120,
  family: 90,
  food: 75,
  historical: 90,
  nature: 120,
  religious: 75,
};

export const TRAVEL_STYLE_CONFIG = {
  relaxed: {
    dayStartMinutes: 10 * 60,
    activeMinutes: 6 * 60,
    paceMultiplier: 1.15,
  },
  balanced: {
    dayStartMinutes: 9 * 60,
    activeMinutes: 8 * 60,
    paceMultiplier: 1,
  },
  packed: {
    dayStartMinutes: 8 * 60,
    activeMinutes: 10 * 60,
    paceMultiplier: 0.9,
  },
};

export const SCORING_WEIGHTS = {
  rating: 0.32,
  categoryMatch: 0.28,
  interestOverlap: 0.14,
  travelStyleFit: 0.12,
  budgetFit: 0.08,
  diversity: 0.06,
};
