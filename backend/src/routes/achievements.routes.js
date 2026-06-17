import { Router } from 'express';

import {
  createXpEvent,
  getMyAchievements,
} from '../controllers/achievements.controller.js';
import { requireAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.use(requireAuth);
router.get('/me', getMyAchievements);
router.post('/events', createXpEvent);

export default router;
