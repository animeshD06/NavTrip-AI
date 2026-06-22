import { getWeatherCrowdInsights } from '../services/weather-crowd.service.js';
import { parseCoordinate } from '../utils/validation.js';

export async function getInsights(req, res, next) {
  try {
    const latitude = req.query.latitude === undefined
      ? null
      : parseCoordinate(req.query.latitude, 'latitude', -90, 90);
    const longitude = req.query.longitude === undefined
      ? null
      : parseCoordinate(req.query.longitude, 'longitude', -180, 180);
    const data = await getWeatherCrowdInsights({
      city: req.query.city,
      latitude,
      longitude,
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}
