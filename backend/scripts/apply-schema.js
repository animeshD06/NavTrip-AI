import 'dotenv/config';

import { readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { pool } from '../src/config/db.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const schemaPath = resolve(__dirname, '../db/schema.sql');

try {
  const schema = await readFile(schemaPath, 'utf8');
  await pool.query(schema);
  console.log('Database schema applied.');
} finally {
  await pool.end();
}
