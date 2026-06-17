import { randomUUID } from 'node:crypto';

const follows = new Set();
const stories = [];

function followKey(followerId, followingId) {
  return `${followerId}:${followingId}`;
}

export function followTraveler({ followerId, followingId }) {
  const key = followKey(followerId, followingId);

  if (follows.has(key)) {
    follows.delete(key);
  } else {
    follows.add(key);
  }

  return {
    followerId,
    followingId,
    following: follows.has(key),
  };
}

export function createStory({ userId, title, body, media = [], routeId = null }) {
  const story = {
    id: randomUUID(),
    userId,
    title,
    body,
    routeId,
    media,
    moderationStatus: 'pending',
    createdAt: new Date().toISOString(),
  };

  stories.unshift(story);
  return story;
}

export function getActivityFeed({ userId, limit = 20 }) {
  const followedIds = new Set(
    Array.from(follows)
      .filter((key) => key.startsWith(`${userId}:`))
      .map((key) => key.split(':')[1]),
  );

  return stories
    .filter((story) => story.userId === userId || followedIds.has(story.userId))
    .slice(0, limit)
    .map((story) => ({
      id: randomUUID(),
      actorId: story.userId,
      activityType: 'story_created',
      entityType: 'travel_story',
      entityId: story.id,
      story,
      createdAt: story.createdAt,
    }));
}
