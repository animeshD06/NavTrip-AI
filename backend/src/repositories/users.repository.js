import crypto from 'node:crypto';

import { pool } from '../config/db.js';

const users = [];

function mapUser(row) {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    passwordHash: row.password_hash,
    createdAt: row.created_at,
  };
}

export async function findUserByEmailFromDatabase(email) {
  const result = await pool.query(
    `
      SELECT id, name, email, password_hash, created_at
      FROM users
      WHERE LOWER(email) = LOWER($1)
    `,
    [email],
  );

  return result.rows[0] ? mapUser(result.rows[0]) : null;
}

export async function createUserInDatabase({ name, email, passwordHash }) {
  const result = await pool.query(
    `
      INSERT INTO users (name, email, password_hash)
      VALUES ($1, $2, $3)
      RETURNING id, name, email, password_hash, created_at
    `,
    [name, email, passwordHash],
  );

  return mapUser(result.rows[0]);
}

export function findUserByEmailInMemory(email) {
  return users.find((user) => user.email.toLowerCase() === email.toLowerCase()) || null;
}

export function createUserInMemory({ name, email, passwordHash }) {
  const user = {
    id: crypto.randomUUID(),
    name,
    email,
    passwordHash,
    createdAt: new Date().toISOString(),
  };

  users.push(user);
  return user;
}
