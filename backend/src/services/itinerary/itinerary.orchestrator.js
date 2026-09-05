import { assignClustersToDays } from './dayAssigner.js';
import { loadDestinationCandidates } from './candidateLoader.js';
import { clusterPlaces } from './clusteringEngine.js';
import { normalizeItineraryInput } from './inputNormalizer.js';
import { routeDayPlaces } from './intraDayRouter.js';
import { scheduleDays } from './timeScheduler.js';
import { selectPlaces } from './selection.js';

export async function buildItinerary(options) {
  const input = normalizeItineraryInput(options);
  const destinationPlaces = await loadDestinationCandidates(input);
  const selectedPlaces = selectPlaces(destinationPlaces.places, input);
  const clusters = clusterPlaces(selectedPlaces);
  const assignedDays = assignClustersToDays(clusters, input);
  const routedDays = routeDayPlaces(assignedDays);
  const planDays = scheduleDays(routedDays, input);

  return {
    destination: destinationPlaces.resolvedDestination || input.destination,
    destinationType: destinationPlaces.destinationType,
    state: destinationPlaces.state,
    categoryPreference: input.category,
    days: planDays,
    totalPlaces: selectedPlaces.length,
    generatedBy: 'rule-based-city-routing',
  };
}
