import { touristPlaces } from '../data/locations-catalog.js';
import { hasDatabaseConfig } from '../config/db.js';
import {
  findPlaceByIdFromDatabase,
  listNearbyPlacesFromDatabase,
  listPlacesFromDatabase,
} from '../repositories/places.repository.js';
import { haversineDistanceKm } from '../utils/distance.js';

function findPlacesInMemory({ city, state, category, search } = {}) {
  return touristPlaces.filter((place) => {
    const matchesCity = city
      ? place.city.toLowerCase() === city.toLowerCase()
      : true;
    const matchesState = state
      ? place.state?.toLowerCase() === state.toLowerCase()
      : true;
    const matchesCategory = category
      ? place.category.toLowerCase() === category.toLowerCase()
      : true;
    const matchesSearch = search
      ? place.name.toLowerCase().includes(search.toLowerCase())
      : true;

    return matchesCity && matchesState && matchesCategory && matchesSearch;
  });
}

function findPlaceByIdInMemory(id) {
  return touristPlaces.find((place) => place.id === id);
}

function findNearbyPlacesInMemory({ latitude, longitude, radiusKm, category }) {
  return findPlacesInMemory({ category })
    .map((place) => ({
      ...place,
      distanceKm: haversineDistanceKm(latitude, longitude, place.latitude, place.longitude),
    }))
    .filter((place) => place.distanceKm <= radiusKm)
    .sort((first, second) => first.distanceKm - second.distanceKm);
}

export async function findPlaces(filters = {}) {
  if (hasDatabaseConfig()) {
    return listPlacesFromDatabase(filters);
  }

  return findPlacesInMemory(filters);
}

export async function findPlaceById(id) {
  if (hasDatabaseConfig()) {
    return findPlaceByIdFromDatabase(id);
  }

  return findPlaceByIdInMemory(id);
}

export async function findNearbyPlaces(filters) {
  if (hasDatabaseConfig()) {
    return listNearbyPlacesFromDatabase(filters);
  }

  return findNearbyPlacesInMemory(filters);
}
