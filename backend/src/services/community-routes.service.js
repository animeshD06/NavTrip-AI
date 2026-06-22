import { randomUUID } from 'node:crypto';

import { findNearbyPlaces, findPlaceById } from './places.service.js';
import { httpError } from '../utils/http.js';

const routes = new Map();
const likes = new Set();
const bookmarks = new Set();
const comments = new Map();
const ratings = new Map();

function now() {
  return new Date().toISOString();
}

function userRouteKey(routeId, userId) {
  return `${routeId}:${userId}`;
}

function requireRoute(id) {
  const route = routes.get(id);

  if (!route || route.deletedAt) {
    throw httpError(404, 'NotFound', 'Community route not found');
  }

  return route;
}

function requireOwner(route, userId) {
  if (route.userId !== userId) {
    throw httpError(403, 'Forbidden', 'Only the route owner can perform this action');
  }
}

function routeStats(routeId) {
  const routeComments = comments.get(routeId) || [];
  const routeRatings = Array.from(ratings.entries())
    .filter(([key]) => key.startsWith(`${routeId}:`))
    .map(([, value]) => value.rating);

  return {
    likes: Array.from(likes).filter((key) => key.startsWith(`${routeId}:`)).length,
    bookmarks: Array.from(bookmarks).filter((key) => key.startsWith(`${routeId}:`)).length,
    comments: routeComments.length,
    averageRating: routeRatings.length
      ? Number((routeRatings.reduce((sum, rating) => sum + rating, 0) / routeRatings.length).toFixed(2))
      : 0,
  };
}

function serializeRoute(route, viewerId) {
  return {
    ...route,
    stats: routeStats(route.id),
    likedByMe: viewerId ? likes.has(userRouteKey(route.id, viewerId)) : false,
    bookmarkedByMe: viewerId ? bookmarks.has(userRouteKey(route.id, viewerId)) : false,
  };
}

export async function createCommunityRoute({
  userId,
  title,
  description,
  coverImage,
  attractionIds,
  budget,
  durationDays,
  difficulty,
  tags,
}) {
  const routePlaces = [];

  for (let index = 0; index < attractionIds.length; index += 1) {
    const place = await findPlaceById(attractionIds[index]);

    if (!place) {
      throw httpError(400, 'BadRequest', `attractions[${index}] does not match a known place`);
    }

    routePlaces.push({
      placeId: place.id,
      name: place.name,
      city: place.city,
      latitude: place.latitude,
      longitude: place.longitude,
      sequenceOrder: index + 1,
    });
  }

  const createdAt = now();
  const route = {
    id: randomUUID(),
    userId,
    title,
    description,
    coverImage,
    attractions: routePlaces,
    budget,
    durationDays,
    difficulty,
    tags,
    status: 'draft',
    moderationStatus: 'pending',
    syncStatus: 'synced',
    createdAt,
    updatedAt: createdAt,
    publishedAt: null,
    deletedAt: null,
  };

  routes.set(route.id, route);
  return serializeRoute(route, userId);
}

export async function updateCommunityRoute({ routeId, userId, updates }) {
  const route = requireRoute(routeId);
  requireOwner(route, userId);

  const nextRoute = {
    ...route,
    ...updates,
    updatedAt: now(),
  };

  routes.set(route.id, nextRoute);
  return serializeRoute(nextRoute, userId);
}

export async function publishCommunityRoute({ routeId, userId }) {
  const route = requireRoute(routeId);
  requireOwner(route, userId);

  const published = {
    ...route,
    status: 'published',
    moderationStatus: 'approved',
    publishedAt: now(),
    updatedAt: now(),
  };

  routes.set(route.id, published);
  return serializeRoute(published, userId);
}

export async function toggleRouteLike({ routeId, userId }) {
  requireRoute(routeId);
  const key = userRouteKey(routeId, userId);

  if (likes.has(key)) {
    likes.delete(key);
  } else {
    likes.add(key);
  }

  return serializeRoute(requireRoute(routeId), userId);
}

export async function toggleRouteBookmark({ routeId, userId }) {
  requireRoute(routeId);
  const key = userRouteKey(routeId, userId);

  if (bookmarks.has(key)) {
    bookmarks.delete(key);
  } else {
    bookmarks.add(key);
  }

  return serializeRoute(requireRoute(routeId), userId);
}

export async function addRouteComment({ routeId, userId, body }) {
  requireRoute(routeId);
  const routeComments = comments.get(routeId) || [];
  const comment = {
    id: randomUUID(),
    routeId,
    userId,
    body,
    moderationStatus: 'pending',
    createdAt: now(),
  };

  routeComments.push(comment);
  comments.set(routeId, routeComments);

  return comment;
}

export async function rateRoute({ routeId, userId, rating }) {
  requireRoute(routeId);
  ratings.set(userRouteKey(routeId, userId), {
    routeId,
    userId,
    rating,
    updatedAt: now(),
  });

  return serializeRoute(requireRoute(routeId), userId);
}

export async function listRoutes({ listType = 'popular', latitude, longitude, viewerId, limit = 20 }) {
  let visibleRoutes = Array.from(routes.values()).filter(
    (route) => route.status === 'published' && !route.deletedAt,
  );

  if (listType === 'nearby' && latitude !== null && longitude !== null) {
    const nearbyPlaces = await findNearbyPlaces({
      latitude,
      longitude,
      radiusKm: 25,
    });
    const nearbyPlaceIds = new Set(nearbyPlaces.map((place) => place.id));
    visibleRoutes = visibleRoutes.filter((route) =>
      route.attractions.some((place) => nearbyPlaceIds.has(place.placeId)),
    );
  }

  return visibleRoutes
    .map((route) => serializeRoute(route, viewerId))
    .sort((first, second) => {
      const firstStats = first.stats.likes + first.stats.bookmarks + first.stats.averageRating;
      const secondStats = second.stats.likes + second.stats.bookmarks + second.stats.averageRating;
      return secondStats - firstStats || second.createdAt.localeCompare(first.createdAt);
    })
    .slice(0, limit);
}

export function getRouteComments(routeId) {
  requireRoute(routeId);
  return comments.get(routeId) || [];
}
