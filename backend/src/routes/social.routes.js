import { Router } from 'express';

import {
  followUser,
  getFeed,
} from '../controllers/social.controller.js';
import { requireAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.use(requireAuth);
router.get('/feed', getFeed);
router.post('/follow/:userId', followUser);

export default router;
