import { Router } from 'express';

import { createTravelStory } from '../controllers/social.controller.js';
import { requireAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.post('/', requireAuth, createTravelStory);

export default router;
