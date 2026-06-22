import { Router } from 'express';

import { queryAssistant } from '../controllers/assistant.controller.js';
import { optionalAuth } from '../middleware/auth.middleware.js';

const router = Router();

router.post('/query', optionalAuth, queryAssistant);

export default router;
