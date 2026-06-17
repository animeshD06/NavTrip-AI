import {
  getAchievementsForUser,
  recordXpEvent,
} from '../services/achievements.service.js';
import { optionalString, requireString } from '../utils/validation.js';

export function getMyAchievements(req, res) {
  return res.json({
    data: getAchievementsForUser(req.user.sub),
  });
}

export function createXpEvent(req, res, next) {
  try {
    const data = recordXpEvent({
      userId: req.user.sub,
      eventType: requireString(req.body.eventType, 'eventType'),
      entityType: optionalString(req.body.entityType, 'entityType'),
      entityId: optionalString(req.body.entityId, 'entityId'),
    });

    return res.status(201).json({ data });
  } catch (error) {
    return next(error);
  }
}
