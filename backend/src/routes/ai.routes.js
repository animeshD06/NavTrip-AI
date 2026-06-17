import { Router } from 'express';

import {
  createAiItinerary,
  createNarration,
} from '../controllers/ai.controller.js';

const router = Router();

router.post('/itinerary', createAiItinerary);
router.post('/narration', createNarration);

export default router;
