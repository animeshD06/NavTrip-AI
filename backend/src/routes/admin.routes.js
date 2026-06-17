import { Router } from 'express';

import { getAdminAnalyticsController } from '../controllers/analytics.controller.js';
import { requireAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.get('/analytics', requireAuth, getAdminAnalyticsController);

export default router;
