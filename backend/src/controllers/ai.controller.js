import {
  generateAiItinerary,
  generateNarrationSummary,
} from '../services/ai.service.js';
import { findPlaceById } from '../services/places.service.js';
import { sendError } from '../utils/http.js';
import {
  parseOptionalMoney,
  parsePositiveInteger,
  requireString,
} from '../utils/validation.js';

export async function createAiItinerary(req, res, next) {
  try {
    const result = await generateAiItinerary({
      destination: requireString(req.body.destination, 'destination'),
      days: parsePositiveInteger(req.body.days, 'days'),
      category: requireString(req.body.category, 'category'),
      budget: parseOptionalMoney(req.body.budget, 'budget'),
    });

    return res.json({ data: result });
  } catch (error) {
    return next(error);
  }
}

export async function createNarration(req, res, next) {
  try {
    const place = await findPlaceById(requireString(req.body.placeId, 'placeId'));

    if (!place) {
      return sendError(res, 404, 'NotFound', 'Tourist place not found');
    }

    const result = await generateNarrationSummary({
      placeName: place.name,
      description: place.description,
      category: place.category,
    });

    return res.json({ data: result });
  } catch (error) {
    return next(error);
  }
}
