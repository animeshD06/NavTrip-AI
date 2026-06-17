import {
  addRouteComment,
  createCommunityRoute,
  listRoutes,
  publishCommunityRoute,
  rateRoute,
  toggleRouteBookmark,
  toggleRouteLike,
  updateCommunityRoute,
} from '../services/community-routes.service.js';
import {
  optionalString,
  parseCoordinate,
  parseEnum,
  parseOptionalInteger,
  parseOptionalMoney,
  parsePagination,
  parseStringArray,
  requireString,
} from '../utils/validation.js';

function routePayload(body) {
  return {
    title: requireString(body.title, 'title'),
    description: optionalString(body.description, 'description', { maxLength: 2000 }),
    coverImage: optionalString(body.coverImage, 'coverImage', { maxLength: 1000 }),
    attractionIds: parseStringArray(body.attractions || body.attractionIds, 'attractions', { maxItems: 30 }),
    budget: parseOptionalMoney(body.budget, 'budget'),
    durationDays: parseOptionalInteger(body.durationDays || body.duration, 'durationDays', {
      min: 1,
      max: 90,
    }) || 1,
    difficulty: parseEnum(body.difficulty, 'difficulty', ['easy', 'moderate', 'hard'], 'easy'),
    tags: parseStringArray(body.tags, 'tags'),
  };
}

export async function createRoute(req, res, next) {
  try {
    const data = await createCommunityRoute({
      userId: req.user.sub,
      ...routePayload(req.body),
    });

    return res.status(201).json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function updateRoute(req, res, next) {
  try {
    const data = await updateCommunityRoute({
      routeId: requireString(req.params.id, 'id'),
      userId: req.user.sub,
      updates: routePayload({ ...req.body, attractions: req.body.attractions || [] }),
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function publishRoute(req, res, next) {
  try {
    const data = await publishCommunityRoute({
      routeId: requireString(req.params.id, 'id'),
      userId: req.user.sub,
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function likeRoute(req, res, next) {
  try {
    const data = await toggleRouteLike({
      routeId: requireString(req.params.id, 'id'),
      userId: req.user.sub,
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function bookmarkRoute(req, res, next) {
  try {
    const data = await toggleRouteBookmark({
      routeId: requireString(req.params.id, 'id'),
      userId: req.user.sub,
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function commentOnRoute(req, res, next) {
  try {
    const data = await addRouteComment({
      routeId: requireString(req.params.id, 'id'),
      userId: req.user.sub,
      body: requireString(req.body.body, 'body'),
    });

    return res.status(201).json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function rateCommunityRoute(req, res, next) {
  try {
    const data = await rateRoute({
      routeId: requireString(req.params.id, 'id'),
      userId: req.user.sub,
      rating: parseOptionalInteger(req.body.rating, 'rating', { min: 1, max: 5 }),
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function listTrendingRoutes(req, res, next) {
  try {
    const { limit } = parsePagination(req.query);
    const data = await listRoutes({
      listType: 'trending',
      viewerId: req.user?.sub,
      limit,
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}

export async function listNearbyRoutes(req, res, next) {
  try {
    const { limit } = parsePagination(req.query);
    const latitude = req.query.latitude === undefined
      ? null
      : parseCoordinate(req.query.latitude, 'latitude', -90, 90);
    const longitude = req.query.longitude === undefined
      ? null
      : parseCoordinate(req.query.longitude, 'longitude', -180, 180);
    const data = await listRoutes({
      listType: 'nearby',
      latitude,
      longitude,
      viewerId: req.user?.sub,
      limit,
    });

    return res.json({ data });
  } catch (error) {
    return next(error);
  }
}
