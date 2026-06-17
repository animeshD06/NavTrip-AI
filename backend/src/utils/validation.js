import { httpError } from './http.js';

export function parsePositiveInteger(value, fieldName) {
  const parsed = Number(value);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw httpError(400, 'BadRequest', `${fieldName} must be a positive integer`);
  }

  return parsed;
}

export function parseCoordinate(value, fieldName, min, max) {
  const parsed = Number(value);

  if (!Number.isFinite(parsed) || parsed < min || parsed > max) {
    throw httpError(400, 'BadRequest', `${fieldName} must be a number between ${min} and ${max}`);
  }

  return parsed;
}

export function requireString(value, fieldName) {
  if (typeof value !== 'string' || value.trim() === '') {
    throw httpError(400, 'BadRequest', `${fieldName} is required`);
  }

  return value.trim();
}

export function parseOptionalMoney(value, fieldName) {
  if (value === undefined || value === null || value === '') {
    return null;
  }

  const parsed = Number(value);

  if (!Number.isFinite(parsed) || parsed < 0) {
    throw httpError(400, 'BadRequest', `${fieldName} must be a non-negative number`);
  }

  return parsed;
}

export function requireEmail(value, fieldName = 'email') {
  const email = requireString(value, fieldName).toLowerCase();

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw httpError(400, 'BadRequest', `${fieldName} must be a valid email address`);
  }

  return email;
}
