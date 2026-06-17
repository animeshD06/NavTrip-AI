import {
  createStory,
  followTraveler,
  getActivityFeed,
} from '../services/social.service.js';
import {
  optionalString,
  parsePagination,
  parseStringArray,
  requireString,
} from '../utils/validation.js';

export function getFeed(req, res) {
  const { limit } = parsePagination(req.query);

  return res.json({
    data: getActivityFeed({
      userId: req.user.sub,
      limit,
    }),
  });
}

export function followUser(req, res, next) {
  try {
    return res.json({
      data: followTraveler({
        followerId: req.user.sub,
        followingId: requireString(req.params.userId, 'userId'),
      }),
    });
  } catch (error) {
    return next(error);
  }
}

export function createTravelStory(req, res, next) {
  try {
    const data = createStory({
      userId: req.user.sub,
      title: requireString(req.body.title, 'title'),
      body: optionalString(req.body.body, 'body', { maxLength: 4000 }),
      media: parseStringArray(req.body.media, 'media', { maxItems: 10 }),
      routeId: optionalString(req.body.routeId, 'routeId'),
    });

    return res.status(201).json({ data });
  } catch (error) {
    return next(error);
  }
}
