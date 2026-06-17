import { buildItinerary } from './itineraries.service.js';
import { findPlaces } from './places.service.js';
import { generateGeminiJson } from './gemini.service.js';

function normalizeName(value) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
}

function placeSummary(place) {
  return {
    id: place.id,
    name: place.name,
    category: place.category,
    city: place.city,
    rating: place.rating,
    openingTime: place.openingTime,
    closingTime: place.closingTime,
  };
}

function validateAiPlaces(aiPlan, availablePlaces) {
  const byName = new Map(
    availablePlaces.map((place) => [normalizeName(place.name), place]),
  );

  const matchedPlaceIds = new Set();
  const unmatchedPlaceNames = [];

  for (const day of aiPlan.days || []) {
    for (const placeName of day.places || []) {
      const place = byName.get(normalizeName(String(placeName)));

      if (place) {
        matchedPlaceIds.add(place.id);
      } else {
        unmatchedPlaceNames.push(String(placeName));
      }
    }
  }

  return {
    matchedPlaceIds,
    unmatchedPlaceNames,
  };
}

export async function generateAiItinerary({ destination, days, category, budget }) {
  const availablePlaces = await findPlaces({ city: destination, category });
  const fallbackPlaces = availablePlaces.length
    ? availablePlaces
    : await findPlaces({ city: destination });

  const prompt = `
You are a tourism itinerary planner.
Create a ${days}-day itinerary for ${destination}.
Preference category: ${category}.
Budget: ${budget || 'not specified'}.

Use only these known places:
${JSON.stringify(fallbackPlaces.map(placeSummary), null, 2)}

Return only JSON in this shape:
{
  "summary": "short practical summary",
  "days": [
    {
      "dayNumber": 1,
      "theme": "short theme",
      "places": ["exact place name from known places"],
      "tips": ["short useful tip"]
    }
  ]
}
`;

  const aiPlan = await generateGeminiJson(prompt);
  const validation = validateAiPlaces(aiPlan, fallbackPlaces);
  const baseItinerary = await buildItinerary({ destination, days, category });

  return {
    generatedBy: 'gemini',
    aiPlan,
    validatedPlaceIds: Array.from(validation.matchedPlaceIds),
    unmatchedPlaceNames: validation.unmatchedPlaceNames,
    databaseItinerary: baseItinerary,
  };
}

export async function generateNarrationSummary({ placeName, description, category }) {
  const prompt = `
Write a concise tourist voice narration for this place.
Place: ${placeName}
Category: ${category}
Description: ${description}

Return only JSON:
{
  "title": "place name",
  "narration": "45 to 70 words, friendly travel-guide tone",
  "warning": "short practical warning or empty string"
}
`;

  return generateGeminiJson(prompt);
}
