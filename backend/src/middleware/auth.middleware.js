import { verifyToken } from '../services/auth.service.js';
import { sendError } from '../utils/http.js';

export function requireAuth(req, res, next) {
  const header = req.get('authorization') || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return sendError(res, 401, 'Unauthorized', 'Bearer token is required');
  }

  try {
    req.user = verifyToken(token);
    return next();
  } catch (error) {
    return sendError(res, 401, 'Unauthorized', 'Invalid or expired token');
  }
}

export function optionalAuth(req, res, next) {
  const header = req.get('authorization') || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return next();
  }

  try {
    req.user = verifyToken(token);
  } catch (error) {
    return sendError(res, 401, 'Unauthorized', 'Invalid or expired token');
  }

  return next();
}
