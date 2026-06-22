import { optimizeItinerary } from '../services/itinerary-optimizer.service.js';
import {
  parseOptionalInteger,
  parseOptionalMoney,
  parseStringArray,
  requireString,
} from '../utils/validation.js';

export async function optimizeItineraryController(req, res, next) {
  try {
    const data = await optimizeItinerary({
      destination: requireString(req.body.destination, 'destination'),
      days: parseOptionalInteger(req.body.days || req.body.travelDays, 'days', {
        min: 1,
        max: 30,
      }) || 1,
      interests: parseStringArray(req.body.interests, 'interests'),
      travelStyle: req.body.travelStyle || 'balanced',
      groupSize: parseOptionalInteger(req.body.groupSize, 'groupSize', {
        min: 1,
        max: 50,
      }) || 1,
      budget: parseOptionalMoney(req.body.budget, 'budget'),
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}
