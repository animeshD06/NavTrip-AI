const XP_BY_EVENT = {
  attraction_visited: 25,
  city_explored: 100,
  state_completed: 250,
  route_completed: 150,
  review_submitted: 40,
};

const SAMPLE_BADGES = [
  { id: 'explorer', name: 'Explorer', description: 'Visited multiple attractions.', category: 'travel' },
  { id: 'historian', name: 'Historian', description: 'Explored historical places.', category: 'historical' },
  { id: 'foodie', name: 'Foodie', description: 'Reviewed food stops.', category: 'food' },
  { id: 'nature-lover', name: 'Nature Lover', description: 'Explored nature places.', category: 'nature' },
  { id: 'adventure-seeker', name: 'Adventure Seeker', description: 'Completed adventure routes.', category: 'adventure' },
];

const xpEvents = new Map();

function userEvents(userId) {
  return xpEvents.get(userId) || [];
}

function levelForXp(xp) {
  return Math.max(1, Math.floor(xp / 250) + 1);
}

function unlockedBadges(events) {
  const eventTypes = new Set(events.map((event) => event.eventType));
  return SAMPLE_BADGES.filter((badge) => {
    if (badge.id === 'explorer') return events.length >= 3;
    if (badge.id === 'historian') return eventTypes.has('historical_visit');
    if (badge.id === 'foodie') return eventTypes.has('review_submitted');
    if (badge.id === 'nature-lover') return eventTypes.has('nature_visit');
    if (badge.id === 'adventure-seeker') return eventTypes.has('route_completed');
    return false;
  });
}

export function recordXpEvent({ userId, eventType, entityType, entityId }) {
  const events = userEvents(userId);
  const duplicate = events.some(
    (event) =>
      event.eventType === eventType &&
      event.entityType === entityType &&
      event.entityId === entityId,
  );

  if (!duplicate) {
    events.push({
      eventType,
      entityType,
      entityId,
      xp: XP_BY_EVENT[eventType] || 10,
      createdAt: new Date().toISOString(),
    });
    xpEvents.set(userId, events);
  }

  return getAchievementsForUser(userId);
}

export function getAchievementsForUser(userId) {
  const events = userEvents(userId);
  const totalXp = events.reduce((sum, event) => sum + event.xp, 0);
  const badges = unlockedBadges(events);

  return {
    userId,
    xp: totalXp,
    level: levelForXp(totalXp),
    currentStreak: events.length ? 1 : 0,
    bestStreak: events.length ? 1 : 0,
    badges,
    recentEvents: events.slice(-10).reverse(),
    availableBadges: SAMPLE_BADGES,
  };
}
