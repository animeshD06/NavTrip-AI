import { env } from '../config/env.js';
import { httpError } from '../utils/http.js';

const GEMINI_API_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta';

function requireGeminiApiKey() {
  if (!env.geminiApiKey) {
    throw httpError(503, 'ServiceUnavailable', 'GEMINI_API_KEY is not configured');
  }
}

function extractText(responseJson) {
  const parts = responseJson.candidates?.[0]?.content?.parts || [];
  return parts.map((part) => part.text || '').join('').trim();
}

function extractJsonObject(text) {
  const fencedMatch = text.match(/```(?:json)?\s*([\s\S]*?)```/i);
  const candidate = fencedMatch?.[1] || text;
  const start = candidate.indexOf('{');
  const end = candidate.lastIndexOf('}');

  if (start === -1 || end === -1 || end <= start) {
    throw httpError(502, 'GeminiResponseError', 'Gemini response did not contain a JSON object');
  }

  return JSON.parse(candidate.slice(start, end + 1));
}

export async function generateGeminiJson(prompt) {
  requireGeminiApiKey();

  const response = await fetch(
    `${GEMINI_API_BASE_URL}/models/${env.geminiModel}:generateContent`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': env.geminiApiKey,
      },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: [{ text: prompt }],
          },
        ],
        generationConfig: {
          temperature: 0.4,
          responseMimeType: 'application/json',
        },
      }),
    },
  );

  if (!response.ok) {
    const body = await response.text();
    throw httpError(response.status, 'GeminiApiError', `Gemini API request failed: ${body}`);
  }

  const responseJson = await response.json();
  return extractJsonObject(extractText(responseJson));
}
