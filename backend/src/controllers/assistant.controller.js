import { answerAssistantQuery } from '../services/assistant.service.js';
import {
  parseCoordinate,
  requireString,
} from '../utils/validation.js';

export async function queryAssistant(req, res, next) {
  try {
    const latitude = req.body.latitude === undefined
      ? null
      : parseCoordinate(req.body.latitude, 'latitude', -90, 90);
    const longitude = req.body.longitude === undefined
      ? null
      : parseCoordinate(req.body.longitude, 'longitude', -180, 180);
    const data = await answerAssistantQuery({
      query: requireString(req.body.query, 'query'),
      city: req.body.city,
      latitude,
      longitude,
      offlinePreferred: req.body.offlinePreferred !== false,
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}
