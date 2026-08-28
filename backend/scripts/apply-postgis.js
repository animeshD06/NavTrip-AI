import 'dotenv/config';

import { readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { pool } from '../src/config/db.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const postgisPath = resolve(__dirname, '../db/postgis.sql');

try {
  const postgisSchema = await readFile(postgisPath, 'utf8');
  await pool.query(postgisSchema);
  console.log('PostGIS indexes applied.');
} finally {
  await pool.end();
}
