import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

import { hasDatabaseConfig } from '../config/db.js';
import { env } from '../config/env.js';
import {
  createUserInDatabase,
  createUserInMemory,
  findUserByEmailFromDatabase,
  findUserByEmailInMemory,
} from '../repositories/users.repository.js';
import { httpError } from '../utils/http.js';

const TOKEN_EXPIRES_IN = '7d';

function publicUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    createdAt: user.createdAt,
  };
}

function signToken(user) {
  const secret = env.jwtSecret || 'development-only-secret';

  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
    },
    secret,
    { expiresIn: TOKEN_EXPIRES_IN },
  );
}

async function findUserByEmail(email) {
  if (hasDatabaseConfig()) {
    return findUserByEmailFromDatabase(email);
  }

  return findUserByEmailInMemory(email);
}

export async function registerUser({ name, email, password }) {
  const existingUser = await findUserByEmail(email);

  if (existingUser) {
    throw httpError(409, 'Conflict', 'Email is already registered');
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const user = hasDatabaseConfig()
    ? await createUserInDatabase({ name, email, passwordHash })
    : createUserInMemory({ name, email, passwordHash });

  return {
    user: publicUser(user),
    token: signToken(user),
  };
}

export async function loginUser({ email, password }) {
  const user = await findUserByEmail(email);

  if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
    throw httpError(401, 'Unauthorized', 'Invalid email or password');
  }

  return {
    user: publicUser(user),
    token: signToken(user),
  };
}

export function verifyToken(token) {
  const secret = env.jwtSecret || 'development-only-secret';
  return jwt.verify(token, secret);
}
