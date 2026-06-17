import pg from 'pg';

import { env } from './env.js';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: env.databaseUrl,
});

export function hasDatabaseConfig() {
  return Boolean(env.databaseUrl);
}

export async function checkDatabaseConnection() {
  if (!env.databaseUrl) {
    return {
      connected: false,
      reason: 'DATABASE_URL is not configured',
    };
  }

  try {
    await pool.query('SELECT 1');
    return {
      connected: true,
    };
  } catch (error) {
    return {
      connected: false,
      reason: error.message,
    };
  }
}
