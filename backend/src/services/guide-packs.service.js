import { createHash, randomUUID } from 'node:crypto';

import { findPlaceById, findPlaces } from './places.service.js';
import { generateNarrationSummary } from './ai.service.js';
import { httpError } from '../utils/http.js';

const narrationCache = new Map();

function normalize(value) {
  return String(value || '').trim().toLowerCase();
}

function narrationKey({ placeId, language, mode }) {
  return `${placeId}:${language}:${mode}`;
}

function buildNarration(place, mode) {
  const prefix = `${place.name}. ${place.description}`;

  if (mode === 'short') {
    return `${place.name}. ${place.category} attraction in ${place.city}. Rating ${place.rating.toFixed(1)} out of 5.`;
  }

  if (mode === 'detailed') {
    return `${prefix} This stop is useful for travelers interested in ${place.category}. Plan your visit between ${place.openingTime || 'local opening hours'} and ${place.closingTime || 'closing time'}, and leave enough time for nearby viewpoints, food, and photos.`;
  }

  return `${prefix} It is rated ${place.rating.toFixed(1)} out of 5 and is a recommended ${place.category} stop in ${place.city}.`;
}

export async function listGuidePacks({ city, language = 'en-IN' } = {}) {
  const places = await findPlaces({ city });
  const cities = new Map();

  places.forEach((place) => {
    const key = normalize(place.city);
    const existing = cities.get(key) || {
      id: randomUUID(),
      city: place.city,
      state: place.state,
      version: '1.0.0',
      language,
      placeCount: 0,
      sizeBytes: 0,
      status: 'active',
    };

    existing.placeCount += 1;
    existing.sizeBytes += JSON.stringify(place).length + 2048;
    cities.set(key, existing);
  });

  return Array.from(cities.values()).sort((first, second) =>
    first.city.localeCompare(second.city),
  );
}

export async function buildDownloadManifest({ city, language = 'en-IN' }) {
  const places = await findPlaces({ city });

  if (!places.length) {
    throw httpError(404, 'NotFound', `No guide pack places found for ${city}`);
  }

  const narrations = places.flatMap((place) =>
    ['short', 'medium', 'detailed'].map((mode) => ({
      placeId: place.id,
      language,
      mode,
      content: buildNarration(place, mode),
      version: '1.0.0',
    })),
  );

  const knowledgeChunks = places.map((place) => ({
    id: randomUUID(),
    city: place.city,
    placeId: place.id,
    title: place.name,
    body: `${place.description} Category: ${place.category}. Rating: ${place.rating.toFixed(1)}.`,
    tags: [place.category, place.city, place.state].filter(Boolean),
    version: '1.0.0',
  }));

  const manifest = {
    id: randomUUID(),
    city: places[0].city,
    state: places[0].state,
    version: '1.0.0',
    language,
    generatedAt: new Date().toISOString(),
    places,
    narrations,
    knowledgeChunks,
    images: [],
  };
  const checksum = createHash('sha256').update(JSON.stringify(manifest)).digest('hex');

  return {
    ...manifest,
    checksum,
    sizeBytes: Buffer.byteLength(JSON.stringify(manifest)),
  };
}

export async function getNarration({ placeId, language = 'en-IN', mode = 'medium' }) {
  const key = narrationKey({ placeId, language, mode });

  if (narrationCache.has(key)) {
    return narrationCache.get(key);
  }

  const place = await findPlaceById(placeId);

  if (!place) {
    throw httpError(404, 'NotFound', 'Tourist place not found');
  }

  let content = buildNarration(place, mode);

  try {
    const aiNarration = await generateNarrationSummary({
      placeName: place.name,
      description: place.description,
      category: place.category,
    });
    content = aiNarration.narration || content;
  } catch (error) {
    content = buildNarration(place, mode);
  }

  const narration = {
    placeId,
    language,
    mode,
    version: '1.0.0',
    content,
    cached: true,
  };

  narrationCache.set(key, narration);
  return narration;
}
