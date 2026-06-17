import { Router } from 'express';

import {
  createDownloadManifest,
  getGuidePacks,
} from '../controllers/guide-packs.controller.js';

const router = Router();

router.get('/', getGuidePacks);
router.post('/:city/download-manifest', createDownloadManifest);

export default router;
