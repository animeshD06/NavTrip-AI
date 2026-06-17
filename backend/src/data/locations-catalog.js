import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

import { touristPlaces as curatedTouristPlaces } from './tourist-places.js';

const locationsFile = fileURLToPath(
  new URL('../../../frontend/build/locations.md', import.meta.url),
);

const cityMeta = {
  Agra: { state: 'Uttar Pradesh', latitude: 27.1767, longitude: 78.0081 },
  Alleppey: { state: 'Kerala', latitude: 9.4981, longitude: 76.3388, canonicalCity: 'Alappuzha' },
  Darjeeling: { state: 'West Bengal', latitude: 27.0410, longitude: 88.2663 },
  Gangtok: { state: 'Sikkim', latitude: 27.3314, longitude: 88.6138 },
  Goa: { state: 'Goa', latitude: 15.4909, longitude: 73.8278 },
  Hampi: { state: 'Karnataka', latitude: 15.3350, longitude: 76.4600 },
  Jaipur: { state: 'Rajasthan', latitude: 26.9124, longitude: 75.7873 },
  Jaisalmer: { state: 'Rajasthan', latitude: 26.9157, longitude: 70.9083 },
  Kochi: { state: 'Kerala', latitude: 9.9312, longitude: 76.2673 },
  Leh: { state: 'Ladakh', latitude: 34.1526, longitude: 77.5771 },
  Manali: { state: 'Himachal Pradesh', latitude: 32.2432, longitude: 77.1892 },
  Munnar: { state: 'Kerala', latitude: 10.0889, longitude: 77.0595 },
  Mysuru: { state: 'Karnataka', latitude: 12.2958, longitude: 76.6394 },
  Nainital: { state: 'Uttarakhand', latitude: 29.3919, longitude: 79.4542 },
  Rishikesh: { state: 'Uttarakhand', latitude: 30.0869, longitude: 78.2676 },
  Shillong: { state: 'Meghalaya', latitude: 25.5788, longitude: 91.8933 },
  Shimla: { state: 'Himachal Pradesh', latitude: 31.1048, longitude: 77.1734 },
  Srinagar: { state: 'Jammu and Kashmir', latitude: 34.0837, longitude: 74.7973 },
  Udaipur: { state: 'Rajasthan', latitude: 24.5854, longitude: 73.7125 },
  Varanasi: { state: 'Uttar Pradesh', latitude: 25.3176, longitude: 82.9739 },
};

const categoryKeywords = [
  ['adventure', ['safari', 'rafting', 'ropeway', 'pass', 'tunnel', 'falls', 'waterfall', 'valley', 'trek', 'hill', 'peak']],
  ['religious', ['temple', 'mandir', 'masjid', 'mosque', 'church', 'monastery', 'shrine', 'ghat', 'aarti', 'ashram', 'niketan', 'stupa', 'pagoda']],
  ['nature', ['lake', 'beach', 'garden', 'gardens', 'park', 'river', 'backwater', 'backwaters', 'forest', 'zoo', 'national park', 'sanctuary', 'dunes', 'view point', 'viewpoint']],
  ['food', ['bazaar', 'market', 'mall']],
  ['historical', ['fort', 'palace', 'haveli', 'museum', 'memorial', 'tomb', 'cenotaph', 'castle', 'gate', 'chariot', 'archaeological', 'ruins']],
];

function slugify(value) {
  return String(value)
    .toLowerCase()
    .replace(/&/g, ' and ')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function inferCategory(name) {
  const normalizedName = name.toLowerCase();
  const match = categoryKeywords.find(([, keywords]) => (
    keywords.some((keyword) => normalizedName.includes(keyword))
  ));

  return match?.[0] || 'family';
}

function buildDescription(name, city, state) {
  return `${name} is a notable tourist stop in ${city}, ${state}.`;
}

function buildCoordinate(meta, index) {
  const ring = Math.floor(index / 8) + 1;
  const angle = (index % 8) * (Math.PI / 4);
  const offset = ring * 0.012;

  return {
    latitude: Number((meta.latitude + Math.sin(angle) * offset).toFixed(6)),
    longitude: Number((meta.longitude + Math.cos(angle) * offset).toFixed(6)),
  };
}

function parseLocationsMarkdown() {
  if (!existsSync(locationsFile)) {
    return [];
  }

  const lines = readFileSync(locationsFile, 'utf8')
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);
  const parsedLocations = [];
  let currentCity = null;
  let placeIndex = 0;

  for (const line of lines) {
    if (/^\d+$/.test(line)) {
      continue;
    }

    const heading = line.match(/^\d+\.\s+(.+?)(?:\s+\(.+\))?$/);

    if (heading) {
      currentCity = heading[1].trim();
      placeIndex = 0;
      continue;
    }

    if (!currentCity || !cityMeta[currentCity]) {
      continue;
    }

    const meta = cityMeta[currentCity];
    const city = meta.canonicalCity || currentCity;
    const coordinates = buildCoordinate(meta, placeIndex);

    parsedLocations.push({
      id: `place_${slugify(city)}_${slugify(line)}`,
      name: line,
      category: inferCategory(line),
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      description: buildDescription(line, city, meta.state),
      city,
      state: meta.state,
      rating: 4.3,
      openingTime: '09:00',
      closingTime: '18:00',
    });
    placeIndex += 1;
  }

  return parsedLocations;
}

function placeKey(place) {
  return `${place.city.toLowerCase()}::${place.name.toLowerCase()}`;
}

const curatedKeys = new Set(curatedTouristPlaces.map(placeKey));
const usedIds = new Set(curatedTouristPlaces.map((place) => place.id));
function ensureUniqueId(place) {
  if (!usedIds.has(place.id)) {
    usedIds.add(place.id);
    return place;
  }

  let suffix = 2;
  let id = `${place.id}_${suffix}`;

  while (usedIds.has(id)) {
    suffix += 1;
    id = `${place.id}_${suffix}`;
  }

  usedIds.add(id);

  return {
    ...place,
    id,
  };
}

const generatedTouristPlaces = parseLocationsMarkdown()
  .filter((place) => !curatedKeys.has(placeKey(place)))
  .map(ensureUniqueId);

export const touristPlaces = [
  ...curatedTouristPlaces,
  ...generatedTouristPlaces,
];

export const importedLocationsCount = generatedTouristPlaces.length;
