import { Router } from 'express';

import { getPlaceNarration } from '../controllers/guide-packs.controller.js';

const router = Router();

router.get('/:placeId', getPlaceNarration);

export default router;
