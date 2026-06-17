import {
  findNearbyPlaces,
  findPlaceById,
  findPlaces,
} from '../services/places.service.js';
import { sendError } from '../utils/http.js';
import { parseCoordinate } from '../utils/validation.js';

export async function getPlaces(req, res, next) {
  try {
    const places = await findPlaces({
      city: req.query.city,
      state: req.query.state,
      category: req.query.category,
      search: req.query.search,
    });

    res.json({ data: places });
  } catch (error) {
    next(error);
  }
}

export async function getNearbyPlaces(req, res, next) {
  try {
    const latitude = parseCoordinate(req.query.latitude, 'latitude', -90, 90);
    const longitude = parseCoordinate(req.query.longitude, 'longitude', -180, 180);
    const radiusKm = parseCoordinate(req.query.radiusKm || 10, 'radiusKm', 0.1, 500);
    const places = await findNearbyPlaces({
      latitude,
      longitude,
      radiusKm,
      category: req.query.category,
    });

    return res.json({ data: places });
  } catch (error) {
    return next(error);
  }
}

export async function getPlaceById(req, res, next) {
  try {
    const place = await findPlaceById(req.params.id);

    if (!place) {
      return sendError(res, 404, 'NotFound', 'Tourist place not found');
    }

    return res.json({ data: place });
  } catch (error) {
    return next(error);
  }
}
