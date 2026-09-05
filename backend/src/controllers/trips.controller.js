import {
  createTripWithItinerary,
  findTripById,
  listTrips,
  removeTrip,
} from '../services/trips.service.js';
import { sendError } from '../utils/http.js';
import {
  parseEnum,
  parseOptionalInteger,
  parseOptionalMoney,
  parsePositiveInteger,
  parseStringArray,
  requireString,
} from '../utils/validation.js';

export async function getTrips(req, res, next) {
  try {
    res.json({ data: await listTrips({ userId: req.user?.sub }) });
  } catch (error) {
    next(error);
  }
}

export async function createTrip(req, res, next) {
  try {
    const destination = requireString(req.body.destination, 'destination');
    const days = parsePositiveInteger(req.body.days, 'days');
    const category = requireString(req.body.category, 'category');
    const trip = await createTripWithItinerary({
      destination,
      days,
      category,
      budget: parseOptionalMoney(req.body.budget, 'budget'),
      interests: parseStringArray(req.body.interests, 'interests'),
      travelStyle: parseEnum(
        req.body.travelStyle,
        'travelStyle',
        ['relaxed', 'balanced', 'moderate', 'packed'],
        'balanced',
      ),
      groupSize: parseOptionalInteger(req.body.groupSize, 'groupSize', { min: 1, max: 20 }),
      userId: req.user?.sub,
    });

    return res.status(201).json({ data: trip });
  } catch (error) {
    return next(error);
  }
}

export async function getTripById(req, res, next) {
  try {
    const trip = await findTripById(req.params.id, { userId: req.user?.sub });

    if (!trip) {
      return sendError(res, 404, 'NotFound', 'Trip not found');
    }

    return res.json({ data: trip });
  } catch (error) {
    return next(error);
  }
}

export async function deleteTrip(req, res, next) {
  try {
    const deleted = await removeTrip(req.params.id, { userId: req.user?.sub });

    if (!deleted) {
      return sendError(res, 404, 'NotFound', 'Trip not found');
    }

    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}
