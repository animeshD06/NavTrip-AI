import { findPlaces } from '../places.service.js';
import { httpError } from '../../utils/http.js';

export async function loadDestinationCandidates(input) {
  const cityPlaces = await findPlaces({ city: input.destination });

  if (cityPlaces.length) {
    return {
      places: cityPlaces,
      destinationType: 'city',
      resolvedDestination: cityPlaces[0].city,
      state: cityPlaces[0].state,
    };
  }

  const statePlaces = await findPlaces({ state: input.destination });

  if (statePlaces.length) {
    return {
      places: statePlaces,
      destinationType: 'state',
      resolvedDestination: statePlaces[0].state,
      state: statePlaces[0].state,
    };
  }

  throw httpError(404, 'NotFound', `No tourist places found for ${input.destination}`);
}
