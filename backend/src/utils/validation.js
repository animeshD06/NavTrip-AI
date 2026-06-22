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

export function optionalString(value, fieldName, { maxLength = 500 } = {}) {
  if (value === undefined || value === null) {
    return '';
  }

  if (typeof value !== 'string') {
    throw httpError(400, 'BadRequest', `${fieldName} must be a string`);
  }

  const trimmed = value.trim();

  if (trimmed.length > maxLength) {
    throw httpError(400, 'BadRequest', `${fieldName} must be ${maxLength} characters or fewer`);
  }

  return trimmed;
}

export function parseOptionalNumber(value, fieldName, { min, max } = {}) {
  if (value === undefined || value === null || value === '') {
    return null;
  }

  const parsed = Number(value);

  if (!Number.isFinite(parsed)) {
    throw httpError(400, 'BadRequest', `${fieldName} must be a number`);
  }

  if (min !== undefined && parsed < min) {
    throw httpError(400, 'BadRequest', `${fieldName} must be at least ${min}`);
  }

  if (max !== undefined && parsed > max) {
    throw httpError(400, 'BadRequest', `${fieldName} must be at most ${max}`);
  }

  return parsed;
}

export function parseOptionalInteger(value, fieldName, { min, max } = {}) {
  if (value === undefined || value === null || value === '') {
    return null;
  }

  const parsed = Number(value);

  if (!Number.isInteger(parsed)) {
    throw httpError(400, 'BadRequest', `${fieldName} must be an integer`);
  }

  if (min !== undefined && parsed < min) {
    throw httpError(400, 'BadRequest', `${fieldName} must be at least ${min}`);
  }

  if (max !== undefined && parsed > max) {
    throw httpError(400, 'BadRequest', `${fieldName} must be at most ${max}`);
  }

  return parsed;
}

export function parseEnum(value, fieldName, allowedValues, fallback) {
  const candidate = value === undefined || value === null || value === ''
    ? fallback
    : String(value).trim().toLowerCase();

  if (!allowedValues.includes(candidate)) {
    throw httpError(400, 'BadRequest', `${fieldName} must be one of: ${allowedValues.join(', ')}`);
  }

  return candidate;
}

export function parseStringArray(value, fieldName, { maxItems = 12 } = {}) {
  if (value === undefined || value === null) {
    return [];
  }

  if (!Array.isArray(value)) {
    throw httpError(400, 'BadRequest', `${fieldName} must be an array`);
  }

  if (value.length > maxItems) {
    throw httpError(400, 'BadRequest', `${fieldName} must include ${maxItems} items or fewer`);
  }

  return value.map((item, index) => requireString(item, `${fieldName}[${index}]`));
}

export function parsePagination(query = {}) {
  return {
    limit: parseOptionalInteger(query.limit, 'limit', { min: 1, max: 100 }) || 20,
    offset: parseOptionalInteger(query.offset, 'offset', { min: 0 }) || 0,
  };
}
