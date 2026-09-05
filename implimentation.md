# AI Tourist Map & Smart Travel Planner Implementation Plan

> Note: file name follows the requested spelling: `implimentation.md`.

## Current Status

- [x] Architecture documented in `arch.md`
- [x] Implementation plan created
- [x] Git repository initialized
- [x] Flutter toolchain available locally at `tools/flutter`
- [x] PostgreSQL available
- [ ] PostGIS available
- [x] Backend scaffold completed
- [x] Frontend source scaffold completed

## Build Strategy

Build the app in layers. The first working milestone should prove the core tourist-map experience before adding advanced AI features.

Priority order:

1. Backend API foundation
2. Tourist place data model and seed data
3. Flutter map screen
4. User location and tourist markers
5. Basic itinerary generation
6. Route display
7. Voice narration
8. Saved trips
9. AI recommendations
10. Offline and production optimization

## Phase 1: Foundation Setup

Goal: create the base project structure and prove frontend/backend connectivity.

Tasks:

- [x] Create `frontend/`
- [x] Create `backend/`
- [x] Create `docs/`
- [x] Initialize Git repository
- [x] Add root `.gitignore`
- [x] Generate Flutter platform files
- [x] Add Flutter app source files
- [x] Run `flutter analyze`
- [x] Run Flutter widget test
- [x] Build Flutter web bundle
- [x] Run full backend and frontend test sweep
- [x] Set up Node.js backend structure
- [x] Add backend environment template
- [x] Add backend health-check endpoint
- [x] Connect Flutter app to backend health endpoint
- [x] Confirm local backend runs

Deliverables:

- Backend responds at `GET /api/health`
- Frontend can call backend
- Environment variables are documented

## Phase 2: Database & Data Models

Goal: prepare the backend for tourist places, trips, and itineraries.

Tables:

- [x] `users`
- [x] `tourist_places`
- [x] `trips`
- [x] `itineraries`

Backend tasks:

- [x] Add PostgreSQL connection using `pg`
- [x] Add database schema file
- [x] Add tourist place seed data
- [x] Add tourist place SQL seed data
- [x] Add temporary in-memory tourist place seed data
- [x] Add repository/service layer for tourist places
- [x] Add nearby-place query
- [x] Add category and city filtering
- [x] Add database schema apply script
- [x] Add database seed script
- [x] Replace tourist places memory reads with database reads when `DATABASE_URL` is configured
- [x] Replace trip memory storage with database-backed persistence when `DATABASE_URL` is configured
- [x] Add database-backed itinerary persistence

Initial APIs:

```http
GET /api/health
GET /api/places
GET /api/places/nearby
GET /api/places/:id
POST /api/trips
GET /api/trips
GET /api/trips/:id
DELETE /api/trips/:id
POST /api/itineraries/generate
GET /api/itineraries/:tripId
```

Deliverables:

- Backend can store and return tourist places
- Backend can create and return generated trips

## Phase 3: Tourism Map MVP

Goal: display a live tourism-only map.

Flutter packages:

```yaml
flutter_map
latlong2
geolocator
dio
provider
```

Tasks:

- [x] Install local Flutter SDK in `tools/flutter`
- [x] Add Flutter app source scaffold
- [x] Add map screen
- [x] Integrate OpenStreetMap tiles in source
- [x] Add user current location source hook
- [x] Fetch tourist places from backend in source
- [x] Display tourist markers in source
- [x] Add category filters
- [x] Add marker detail bottom sheet

Allowed marker categories:

- Tourist attractions
- Hotels
- Restaurants
- Railway stations
- Bus stands
- Airports
- Emergency services

Deliverable:

- Interactive map that shows only tourism-relevant places

## Phase 4: Tourist Place Management

Goal: make places dynamic and searchable.

Tasks:

- [x] Seed initial destination data
- [x] Add city filter
- [x] Add category filter
- [x] Add search by place name
- [x] Add search by destination
- [x] Add Haversine nearby sorting
- [ ] Upgrade to PostGIS spatial queries when database is ready

Deliverable:

- User can search, filter, and discover tourist places

## Phase 5: Itinerary Generator

Goal: generate day-wise travel plans without AI first.

Inputs:

- Destination
- Number of days
- Travel category
- Budget optional

Rule-based logic:

- [x] Fetch places by destination/category
- [x] Sort by rating
- [x] Sort by distance
- [x] Group nearby attractions
- [x] Distribute places across days
- [x] Assign sequence order
- [x] Estimate visit time
- [x] Estimate travel time
- [x] Add initial rule-based itinerary endpoint
- [x] Add in-memory trip creation endpoint

Deliverable:

- Generated day-wise itinerary

## Phase 6: Route Display

Goal: show the itinerary route on the map.

Tasks:

- [x] Draw polylines between itinerary places
- [x] Calculate approximate distance in backend itinerary output
- [x] Estimate travel time in backend itinerary output
- [x] Add route preview screen
- [x] Add navigation-style place ordering
- [ ] Later replace straight-line routes with OSRM road routes

Deliverable:

- Itinerary route visible on map

## Phase 7: Voice Narration

Goal: make the app behave like a tourist guide.

Flutter package:

```yaml
flutter_tts
```

Tasks:

- [x] Add voice service
- [x] Narrate marker details on tap
- [x] Narrate nearby place automatically
- [x] Add distance trigger threshold
- [x] Add cooldown to prevent repeated narration
- [x] Add speech settings
- [x] Add language support

Deliverable:

- Voice-guided tourist narration

## Phase 8: Saved Trips

Goal: allow users to reload itineraries.

Tasks:

- [x] Save generated trips in backend
- [x] Save itinerary places and order
- [ ] Add Saved Trips screen
- [x] Add Trip Detail screen
- [x] Add delete trip action
- [x] Optionally cache trips locally with Hive/shared_preferences

Deliverable:

- Users can save and reopen trips

## Phase 9: AI Recommendations

Goal: add Gemini-powered suggestions after the core map system works.

Tasks:

- [x] Add Gemini API key to backend env
- [x] Add AI service module
- [x] Add prompt templates
- [x] Generate itinerary suggestions
- [x] Match AI suggestions against real database places
- [x] Validate AI output before saving
- [x] Generate concise narration summaries

Important rule:

Do not trust AI for coordinates, database IDs, or business-critical data. Use AI for recommendations, then validate against the database.

Deliverable:

- AI-assisted itinerary planner

## Phase 10: Production Optimization

Goal: prepare the app for real users.

Tasks:

- [x] Add marker clustering
- [x] Add offline saved trips
- [x] Add loading and error states
- [x] Add dark mode
- [x] Add JWT authentication
- [x] Add database indexes
- [x] Add PostGIS indexes
- [x] Add backend validation
- [x] Add rate limiting
- [x] Add deployment config

Deployment targets:

- Frontend web: Firebase Hosting, Vercel, or Netlify
- Backend: Render, Railway, or Fly.io
- Database: Supabase, Neon, or Railway PostgreSQL

## Backend Remaining Work Tracker

Database persistence:

- [x] Add `pg` connection helper
- [x] Add PostgreSQL schema
- [x] Add schema runner script
- [x] Add tourist place SQL seed data
- [x] Add seed runner script
- [x] Add database repositories with memory fallback
- [x] Make places APIs database-backed when `DATABASE_URL` exists
- [x] Make trip APIs database-backed when `DATABASE_URL` exists
- [x] Make itinerary APIs database-backed when `DATABASE_URL` exists
- [x] Add SQL Haversine nearby-place query for local PostgreSQL
- [ ] Upgrade nearby-place query to PostGIS after PostGIS installation

Trip and itinerary logic:

- [x] Add route distance calculation
- [x] Add travel-time estimation
- [x] Improve itinerary grouping by distance
- [x] Store estimated travel minutes

Authentication:

- [x] Add register/login APIs
- [x] Add password hashing
- [x] Add JWT issuing
- [x] Add auth middleware
- [x] Attach saved trips to users

API hardening:

- [x] Add request validation
- [x] Add consistent error responses
- [x] Add rate limiting
- [x] Add environment-specific CORS
- [x] Add backend tests

AI integration:

- [x] Add Gemini service
- [x] Add prompt templates
- [x] Add AI itinerary endpoint
- [x] Validate AI suggestions against database places
- [x] Add AI narration summaries

## First 7-Day Milestone

Target deliverables:

- [x] Backend runs locally
- [x] Health endpoint working
- [x] Database connection working
- [x] Tourist places API working
- [x] Flutter app running in browser
- [x] OpenStreetMap visible in browser
- [x] User location visible after Flutter SDK installation and device permission
- [x] Tourist markers loaded from backend
- [x] Marker detail UI working

## Local Tooling Notes

Detected on this machine:

- Node.js: available
- npm: available
- Flutter: available locally at `tools/flutter/bin/flutter.bat`
- Dart: available through local Flutter SDK
- `psql`: available at `C:\Program Files\PostgreSQL\18\bin\psql.exe`

Immediate next work:

1. Add automatic nearby voice narration with threshold and cooldown.
2. Add user-facing speech settings.
3. Connect frontend health check/startup status to backend.
4. Upgrade nearby-place query to PostGIS after PostGIS is available.
5. Enable Windows Developer Mode if desktop Flutter builds are needed.

## Latest Test Sweep

Date: 2026-05-26

- [x] Backend JavaScript syntax checks
- [x] Database schema apply
- [x] Database seed apply
- [x] PostgreSQL table/count verification
- [x] API health smoke test
- [x] Places API smoke test
- [x] Nearby places API smoke test
- [x] Validation error smoke test
- [x] Auth register smoke test
- [x] Token-owned trip create/list/delete smoke test
- [x] Itinerary persistence smoke test
- [x] Flutter dependency resolution
- [x] Flutter analyze
- [x] Flutter widget test
- [x] Flutter web build

## Advanced Feature Implementation Pass

Date: 2026-06-18

- [x] Added advanced PostgreSQL schema tables for guide packs, narration cache, community routes, recommendations, offline knowledge, optimization runs, achievements, social features, weather/crowd insights, analytics, and admin reporting.
- [x] Added backend API groups for guide packs, narrations, community routes, hidden gems, offline assistant, itinerary optimization, achievements, social feed/follows, stories, weather/crowd insights, analytics events, and admin analytics.
- [x] Added deterministic local-mode services so advanced APIs work without external AI, weather, AR, or database dependencies during development.
- [x] Extended Flutter API client for the new advanced endpoints.
- [x] Extended voice narration with short, medium, and detailed modes plus language selection.
- [x] Added geofenced auto narration service with 50m/100m/200m radius settings and cooldown behavior.
- [x] Added in-memory offline guide-pack cache and offline assistant search abstraction.
- [x] Added AR exploration service bridge with mobile-ready support detection and web/desktop map fallback.
- [x] Added map UI controls for auto guide, radius, narration mode, stop narration, current location, and AR fallback.
- [x] Added backend tests covering the new advanced endpoint groups.
- [x] Ran backend test suite successfully.
- [x] Ran Flutter analyze successfully.
- [x] Ran Flutter widget test successfully.

Remaining production hardening:

- [ ] Replace local-mode advanced feature stores with database-backed repositories for all write-heavy social/community/analytics features.
- [ ] Replace in-memory Flutter offline cache with durable SQLite/Hive storage.
- [ ] Add authenticated media upload/storage integration for cover images, stories, and reviews.
- [ ] Add real OpenWeather provider integration behind the weather/crowd service.
- [ ] Add native ARCore/ARKit package integration behind the AR exploration service.
- [ ] Add admin role enforcement once user roles exist.
