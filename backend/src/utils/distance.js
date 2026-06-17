const EARTH_RADIUS_KM = 6371;

function toRadians(degrees) {
  return degrees * (Math.PI / 180);
}

export function haversineDistanceKm(firstLat, firstLng, secondLat, secondLng) {
  const latitudeDelta = toRadians(secondLat - firstLat);
  const longitudeDelta = toRadians(secondLng - firstLng);

  const a =
    Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(toRadians(firstLat)) *
      Math.cos(toRadians(secondLat)) *
      Math.sin(longitudeDelta / 2) ** 2;

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return Number((EARTH_RADIUS_KM * c).toFixed(2));
}
