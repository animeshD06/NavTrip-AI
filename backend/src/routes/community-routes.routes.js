import { Router } from 'express';

import {
  bookmarkRoute,
  commentOnRoute,
  createRoute,
  likeRoute,
  listNearbyRoutes,
  listTrendingRoutes,
  publishRoute,
  rateCommunityRoute,
  updateRoute,
} from '../controllers/community-routes.controller.js';
import { optionalAuth, requireAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.get('/trending', optionalAuth, listTrendingRoutes);
router.get('/nearby', optionalAuth, listNearbyRoutes);
router.post('/', requireAuth, createRoute);
router.patch('/:id', requireAuth, updateRoute);
router.post('/:id/publish', requireAuth, publishRoute);
router.post('/:id/like', requireAuth, likeRoute);
router.post('/:id/bookmark', requireAuth, bookmarkRoute);
router.post('/:id/comments', requireAuth, commentOnRoute);
router.post('/:id/ratings', requireAuth, rateCommunityRoute);

export default router;
