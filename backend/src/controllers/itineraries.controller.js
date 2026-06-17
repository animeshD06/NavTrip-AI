import { buildItinerary } from '../services/itineraries.service.js';
import { findItineraryByTripId } from '../services/trips.service.js';
import { sendError } from '../utils/http.js';
import { parsePositiveInteger, requireString } from '../utils/validation.js';

export async function generateItinerary(req, res, next) {
  try {
    const destination = requireString(req.body.destination, 'destination');
    const days = parsePositiveInteger(req.body.days, 'days');
    const category = requireString(req.body.category, 'category');
    const itinerary = await buildItinerary({
      destination,
      days,
      category,
    });

    return res.json({ data: itinerary });
  } catch (error) {
    return next(error);
  }
}

export async function getItineraryByTripId(req, res, next) {
  try {
    const itinerary = await findItineraryByTripId(req.params.tripId, {
      userId: req.user?.sub,
    });

    if (!itinerary) {
      return sendError(res, 404, 'NotFound', 'Itinerary not found for this trip');
    }

    return res.json({ data: itinerary });
  } catch (error) {
    return next(error);
  }
}
