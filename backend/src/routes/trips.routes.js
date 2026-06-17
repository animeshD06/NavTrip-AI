import { Router } from 'express';

import {
  createTrip,
  deleteTrip,
  getTripById,
  getTrips,
} from '../controllers/trips.controller.js';
import { optionalAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.use(optionalAuth);

router.get('/', getTrips);
router.post('/', createTrip);
router.get('/:id', getTripById);
router.delete('/:id', deleteTrip);

export default router;
