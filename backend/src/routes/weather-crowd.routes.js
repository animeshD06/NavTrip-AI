import { Router } from 'express';

import { getInsights } from '../controllers/weather-crowd.controller.js';

const router = Router();

router.get('/insights', getInsights);

export default router;
