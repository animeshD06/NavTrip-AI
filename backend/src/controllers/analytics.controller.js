import {
  getAdminAnalytics,
  recordAnalyticsEvent,
} from '../services/analytics.service.js';
import { optionalString, requireString } from '../utils/validation.js';

export function createAnalyticsEvent(req, res, next) {
  try {
    const data = recordAnalyticsEvent({
      userId: req.user?.sub || null,
      sessionId: optionalString(req.body.sessionId, 'sessionId'),
      feature: requireString(req.body.feature, 'feature'),
      eventName: requireString(req.body.eventName, 'eventName'),
      entityType: optionalString(req.body.entityType, 'entityType'),
      entityId: optionalString(req.body.entityId, 'entityId'),
      metadata: req.body.metadata && typeof req.body.metadata === 'object'
        ? req.body.metadata
        : {},
    });

    return res.status(201).json({ data });
  } catch (error) {
    return next(error);
  }
}

export function getAdminAnalyticsController(req, res) {
  return res.json({ data: getAdminAnalytics() });
}
