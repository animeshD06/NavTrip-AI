import { haversineDistanceKm } from '../../utils/distance.js';
import { TRAVEL_STYLE_CONFIG, VISIT_MINUTES_BY_CATEGORY } from './plannerConfig.js';

function normalize(value) {
  return String(value || '').trim().toLowerCase();
}

export function estimateVisitMinutes(category, travelStyle = 'balanced') {
  const baseMinutes = VISIT_MINUTES_BY_CATEGORY[normalize(category)] || 90;
  const multiplier = TRAVEL_STYLE_CONFIG[travelStyle]?.paceMultiplier || 1;

  return Math.max(45, Math.round(baseMinutes * multiplier));
}

function clusterLoadMinutes(cluster, travelStyle) {
  const visitMinutes = cluster.places.reduce(
    (sum, place) => sum + estimateVisitMinutes(place.category, travelStyle),
    0,
  );
  const travelMinutes = Math.max(0, cluster.places.length - 1) * 20;

  return visitMinutes + travelMinutes;
}

function clusterDayDistance(day, cluster) {
  if (!day.clusters.length) {
    return 0;
  }

  return Math.min(
    ...day.clusters.map((existingCluster) =>
      haversineDistanceKm(
        existingCluster.centroid.latitude,
        existingCluster.centroid.longitude,
        cluster.centroid.latitude,
        cluster.centroid.longitude,
      ),
    ),
  );
}

export function assignClustersToDays(clusters, input) {
  const dayBudget = TRAVEL_STYLE_CONFIG[input.travelStyle].activeMinutes;
  const days = Array.from({ length: input.dayCount }, (_, index) => ({
    dayNumber: index + 1,
    clusters: [],
    loadMinutes: 0,
  }));

  const sortedClusters = [...clusters].sort(
    (first, second) =>
      clusterLoadMinutes(second, input.travelStyle) - clusterLoadMinutes(first, input.travelStyle),
  );

  for (const cluster of sortedClusters) {
    const load = clusterLoadMinutes(cluster, input.travelStyle);
    const rankedDays = [...days].sort((first, second) => {
      const firstOverflow = Math.max(0, first.loadMinutes + load - dayBudget);
      const secondOverflow = Math.max(0, second.loadMinutes + load - dayBudget);

      return (
        firstOverflow - secondOverflow ||
        first.loadMinutes - second.loadMinutes ||
        clusterDayDistance(first, cluster) - clusterDayDistance(second, cluster)
      );
    });

    rankedDays[0].clusters.push(cluster);
    rankedDays[0].loadMinutes += load;
  }

  return days.map((day) => ({
    dayNumber: day.dayNumber,
    places: day.clusters.flatMap((cluster) => cluster.places),
  }));
}
