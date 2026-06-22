import { Router } from 'express';

import {
  generateItinerary,
  getItineraryByTripId,
} from '../controllers/itineraries.controller.js';
import { optimizeItineraryController } from '../controllers/itinerary-optimizer.controller.js';
import { optionalAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.use(optionalAuth);

router.post('/generate', generateItinerary);
router.post('/optimize', optimizeItineraryController);
router.get('/:tripId', getItineraryByTripId);

export default router;
