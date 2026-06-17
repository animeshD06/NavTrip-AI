import {
  buildDownloadManifest,
  getNarration,
  listGuidePacks,
} from '../services/guide-packs.service.js';
import { parseEnum, requireString } from '../utils/validation.js';

export async function getGuidePacks(req, res, next) {
  try {
    const data = await listGuidePacks({
      city: req.query.city,
      language: req.query.language || 'en-IN',
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function createDownloadManifest(req, res, next) {
  try {
    const data = await buildDownloadManifest({
      city: requireString(req.params.city, 'city'),
      language: req.body.language || req.query.language || 'en-IN',
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function getPlaceNarration(req, res, next) {
  try {
    const data = await getNarration({
      placeId: requireString(req.params.placeId, 'placeId'),
      language: req.query.language || 'en-IN',
      mode: parseEnum(req.query.mode, 'mode', ['short', 'medium', 'detailed'], 'medium'),
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}
