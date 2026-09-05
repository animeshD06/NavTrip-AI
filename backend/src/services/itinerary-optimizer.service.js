import { buildItinerary } from './itineraries.service.js';

function placeCost(place, groupSize) {
  const base = place.category === 'food' ? 450 : 250;
  return base * groupSize;
}

export async function optimizeItinerary({
  destination,
  days,
  interests,
  travelStyle,
  groupSize,
  budget,
}) {
  const preferredCategory = interests[0] || 'historical';
  const itinerary = await buildItinerary({
    destination,
    days,
    category: preferredCategory,
    interests,
    travelStyle,
    groupSize,
    budget,
  });

  const optimizedDays = itinerary.days.map((day) => ({
    ...day,
    places: [...day.places]
      .sort((first, second) => {
        const firstTiming = first.openingTime || '09:00';
        const secondTiming = second.openingTime || '09:00';
        return firstTiming.localeCompare(secondTiming) || first.travelDistanceKm - second.travelDistanceKm;
      })
      .map((place, index) => ({
        ...place,
        sequenceOrder: index + 1,
        estimatedCost: placeCost(place, groupSize),
        bestVisitWindow: index === 0 ? '08:00-10:00' : '10:30-16:00',
      })),
  }));
  const totalCost = optimizedDays.reduce(
    (sum, day) => sum + day.places.reduce((daySum, place) => daySum + place.estimatedCost, 0),
    0,
  );

  return {
    generatedBy: 'deterministic-route-optimizer',
    inputs: {
      destination,
      days,
      interests,
      travelStyle,
      groupSize,
      budget,
    },
    optimizedRoute: {
      ...itinerary,
      days: optimizedDays,
      totalEstimatedCost: totalCost,
      budgetStatus: budget === null ? 'not_provided' : totalCost <= budget ? 'within_budget' : 'over_budget',
    },
    rationale: [
      'Places are ordered by opening time and short local hops.',
      'Costs are estimated per group size and can be refined with live pricing later.',
      'Weather, traffic, and crowd integrations are service-ready and deterministic in local mode.',
    ],
  };
}
