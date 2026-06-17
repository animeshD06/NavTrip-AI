import { getHiddenGemRecommendations } from '../services/recommendations.service.js';
import {
  parseCoordinate,
  parseOptionalInteger,
  parseStringArray,
} from '../utils/validation.js';

export async function getHiddenGems(req, res, next) {
  try {
    const latitude = req.query.latitude === undefined
      ? null
      : parseCoordinate(req.query.latitude, 'latitude', -90, 90);
    const longitude = req.query.longitude === undefined
      ? null
      : parseCoordinate(req.query.longitude, 'longitude', -180, 180);
    const interests = req.query.interests
      ? String(req.query.interests).split(',').map((item) => item.trim()).filter(Boolean)
      : parseStringArray(req.body?.interests, 'interests');
    const data = await getHiddenGemRecommendations({
      city: req.query.city,
      latitude,
      longitude,
      interests,
      includeVisited: req.query.includeVisited === 'true',
      limit: parseOptionalInteger(req.query.limit, 'limit', { min: 1, max: 50 }) || 10,
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}
