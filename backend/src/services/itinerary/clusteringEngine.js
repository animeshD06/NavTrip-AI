import { haversineDistanceKm } from '../../utils/distance.js';
import { CLUSTER_RADIUS_KM, MAX_PLACES_PER_DAY } from './plannerConfig.js';

function centroidFor(places) {
  const totals = places.reduce(
    (sum, place) => ({
      latitude: sum.latitude + place.latitude,
      longitude: sum.longitude + place.longitude,
    }),
    { latitude: 0, longitude: 0 },
  );

  return {
    latitude: totals.latitude / places.length,
    longitude: totals.longitude / places.length,
  };
}

function clusterDistance(firstCluster, secondCluster) {
  const firstCentroid = centroidFor(firstCluster.places);
  const secondCentroid = centroidFor(secondCluster.places);

  return haversineDistanceKm(
    firstCentroid.latitude,
    firstCentroid.longitude,
    secondCentroid.latitude,
    secondCentroid.longitude,
  );
}

export function clusterPlaces(places, radiusKm = CLUSTER_RADIUS_KM) {
  let clusters = places.map((place, index) => ({
    id: `cluster_${index + 1}`,
    places: [place],
  }));

  while (clusters.length > 1) {
    let bestPair = null;
    let bestDistance = Number.POSITIVE_INFINITY;

    for (let firstIndex = 0; firstIndex < clusters.length; firstIndex += 1) {
      for (let secondIndex = firstIndex + 1; secondIndex < clusters.length; secondIndex += 1) {
        const distance = clusterDistance(clusters[firstIndex], clusters[secondIndex]);

        if (distance < bestDistance) {
          bestDistance = distance;
          bestPair = [firstIndex, secondIndex];
        }
      }
    }

    if (!bestPair || bestDistance > radiusKm) {
      break;
    }

    const [firstIndex, secondIndex] = bestPair;
    clusters[firstIndex] = {
      id: clusters[firstIndex].id,
      places: [...clusters[firstIndex].places, ...clusters[secondIndex].places],
    };
    clusters = clusters.filter((_, index) => index !== secondIndex);
  }

  const splitClusters = clusters.flatMap((cluster) => {
    const orderedPlaces = [...cluster.places].sort(
      (first, second) => second.score - first.score || first.name.localeCompare(second.name),
    );
    const chunks = [];

    for (let index = 0; index < orderedPlaces.length; index += MAX_PLACES_PER_DAY) {
      chunks.push(orderedPlaces.slice(index, index + MAX_PLACES_PER_DAY));
    }

    return chunks;
  });

  return splitClusters.map((clusterPlacesChunk, index) => ({
    id: `cluster_${index + 1}`,
    centroid: centroidFor(clusterPlacesChunk),
    places: clusterPlacesChunk.map((place) => ({
      ...place,
      clusterId: `cluster_${index + 1}`,
    })),
  }));
}
