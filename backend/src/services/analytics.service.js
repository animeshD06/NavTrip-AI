const events = [];

export function recordAnalyticsEvent({
  userId,
  sessionId,
  feature,
  eventName,
  entityType,
  entityId,
  metadata,
}) {
  const event = {
    id: `${Date.now()}-${events.length + 1}`,
    userId,
    sessionId,
    feature,
    eventName,
    entityType,
    entityId,
    metadata,
    createdAt: new Date().toISOString(),
  };

  events.push(event);
  return event;
}

export function getAdminAnalytics() {
  const featureCounts = events.reduce((counts, event) => {
    counts[event.feature] = (counts[event.feature] || 0) + 1;
    return counts;
  }, {});

  return {
    totalEvents: events.length,
    featureCounts,
    narrationUsage: featureCounts.voiceTour || 0,
    badgeProgressionEvents: events.filter((event) => event.feature === 'achievements').length,
    userEngagement: {
      activeUsers: new Set(events.map((event) => event.userId).filter(Boolean)).size,
      sessions: new Set(events.map((event) => event.sessionId).filter(Boolean)).size,
    },
    recentEvents: events.slice(-25).reverse(),
  };
}
