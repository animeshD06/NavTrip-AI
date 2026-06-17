export function httpError(statusCode, name, message) {
  const error = new Error(message);
  error.statusCode = statusCode;
  error.name = name;
  return error;
}

export function sendError(res, statusCode, name, message) {
  return res.status(statusCode).json({
    error: name,
    message,
  });
}
