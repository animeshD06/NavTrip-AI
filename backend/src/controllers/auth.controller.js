import { loginUser, registerUser } from '../services/auth.service.js';
import { httpError } from '../utils/http.js';
import { requireEmail, requireString } from '../utils/validation.js';

function requirePassword(value) {
  const password = requireString(value, 'password');

  if (password.length < 8) {
    throw httpError(400, 'BadRequest', 'password must be at least 8 characters');
  }

  return password;
}

export async function register(req, res, next) {
  try {
    const result = await registerUser({
      name: requireString(req.body.name, 'name'),
      email: requireEmail(req.body.email),
      password: requirePassword(req.body.password),
    });

    return res.status(201).json({ data: result });
  } catch (error) {
    return next(error);
  }
}

export async function login(req, res, next) {
  try {
    const result = await loginUser({
      email: requireEmail(req.body.email),
      password: requireString(req.body.password, 'password'),
    });

    return res.json({ data: result });
  } catch (error) {
    return next(error);
  }
}
