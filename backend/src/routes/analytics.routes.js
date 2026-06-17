import { Router } from 'express';

import { createAnalyticsEvent } from '../controllers/analytics.controller.js';
import { optionalAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.post('/events', optionalAuth, createAnalyticsEvent);

export default router;
