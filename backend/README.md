# NavTrip AI Backend

Node.js + Express API for the AI Tourist Map & Smart Travel Planner.

## Setup

```bash
npm install
npm run dev
```

Copy `.env.example` to `.env` before running locally.

## Current Endpoints

```http
GET /api/health
POST /api/auth/register
POST /api/auth/login
GET /api/places
GET /api/places/nearby
GET /api/places/:id
POST /api/trips
GET /api/trips
GET /api/trips/:id
DELETE /api/trips/:id
POST /api/itineraries/generate
GET /api/itineraries/:tripId
POST /api/ai/itinerary
POST /api/ai/narration
```

Authenticated trip requests use `Authorization: Bearer <token>`. Anonymous trips remain separate from user-owned trips.
