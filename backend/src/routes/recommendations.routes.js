import { Router } from 'express';

import { getHiddenGems } from '../controllers/recommendations.controller.js';
import { optionalAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.get('/hidden-gems', optionalAuth, getHiddenGems);

export default router;
