import { checkDatabaseConnection } from '../config/db.js';
import { env } from '../config/env.js';

export async function getHealth(req, res) {
  const database = await checkDatabaseConnection();

  res.json({
    status: 'ok',
    service: 'navtrip-ai-backend',
    environment: env.nodeEnv,
    database,
    timestamp: new Date().toISOString(),
  });
}
