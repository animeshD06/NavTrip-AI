import { Router } from 'express';

import {
  getNearbyPlaces,
  getPlaceById,
  getPlaces,
} from '../controllers/places.controller.js';

const router = Router();

router.get('/', getPlaces);
router.get('/nearby', getNearbyPlaces);
router.get('/:id', getPlaceById);

export default router;
