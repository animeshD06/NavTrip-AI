Add the following advanced travel features into the existing Tourist Map / Travel Planner application.

IMPORTANT:
- Use the existing architecture, database, authentication, APIs, and UI patterns.
- Reuse existing services and components wherever possible.
- Do not create duplicate systems.
- Keep all features modular and scalable.
- Follow Clean Architecture and SOLID principles.

---

# 1. AI VOICE TOUR GUIDE

Implement an AI-powered voice guide that automatically narrates nearby attractions.

Features:
- Geofencing (50m, 100m, 200m radius)
- Auto-trigger narration when approaching attractions
- Short, Medium, and Detailed narration modes
- Historical information
- Cultural significance
- Local legends and stories
- Multi-language support

Recommended Stack:
- GPS: Geolocator / Native Location APIs
- TTS: Flutter TTS
- AI Content: Gemini API or OpenAI
- Storage: SQLite/Hive for offline caching
- Audio Cache: Local device storage

Requirements:
- Offline narration support
- Downloadable city guide packs
- Smart cooldown to avoid repeated narration

---

# 2. COMMUNITY TRAVEL ROUTES

Allow travelers to create and share custom travel routes.

Features:
- Create route
- Edit route
- Publish route
- Save route
- Share route
- Route ratings
- Likes
- Comments
- Bookmarks

Route Fields:
- Title
- Description
- Cover Image
- Attractions
- Budget
- Duration
- Difficulty
- Tags

Recommended Stack:
- PostgreSQL
- Existing User System
- Existing Media Storage
- Existing APIs

Additional:
- Trending routes
- Nearby routes
- Popular routes
- Hidden gem routes

---

# 3. HIDDEN GEMS RECOMMENDATION ENGINE

Create an AI recommendation system that suggests:

- Hidden attractions
- Local favorites
- Secret viewpoints
- Less crowded places
- Authentic local experiences

Recommendation Factors:
- User interests
- Current location
- Ratings
- Visit history
- Saved places
- Weather

Recommended Stack:
- AI Recommendation Layer
- PostgreSQL
- Existing User Profile Data
- Existing Attraction Data

---

# 4. OFFLINE AI ASSISTANT

Build an offline travel assistant.

Supported Queries:
- What is this monument?
- Tell me about this place.
- What should I visit nearby?
- Where should I eat nearby?
- Local travel tips.

Requirements:
- Works without internet
- Downloadable city knowledge packs
- Fast local search
- Cached attraction data

Recommended Stack:
- SQLite
- Hive
- Local Embeddings
- Vector Search
- ONNX Mobile Models (optional)

---

# 5. SMART ITINERARY OPTIMIZER

Upgrade itinerary planning using AI.

Inputs:
- Budget
- Travel days
- Interests
- Travel style
- Group size

Outputs:
- Optimized route
- Time estimates
- Cost estimates
- Best visit order

Optimization Factors:
- Weather
- Distance
- Traffic
- Crowd levels
- Attraction timings

Recommended Stack:
- Gemini/OpenAI
- Weather API
- Existing Map Services
- Route Optimization Algorithms

---

# 6. GAMIFICATION SYSTEM

Create a complete travel achievement system.

Track:
- Attractions visited
- Cities explored
- States completed
- Routes completed
- Reviews submitted

Features:
- XP System
- Levels
- Badges
- Achievements
- Travel Streaks

Sample Badges:
- Explorer
- Historian
- Foodie
- Nature Lover
- Adventure Seeker

Recommended Stack:
- PostgreSQL
- Existing User Profiles
- Achievement Service

---

# 7. AR EXPLORATION MODE

Implement Augmented Reality tourism experience.

Features:
- Point camera at attraction
- Detect landmark
- Display overlay information
- Historical facts
- Ratings
- Distance
- Navigation arrows

Recommended Stack:
- ARCore (Android)
- ARKit (iOS)
- Flutter AR packages
- Landmark Recognition APIs
- Existing Attraction Database

Future Ready:
- Modular AR layer for easy SDK replacement

---

# 8. SMART WEATHER & CROWD INSIGHTS

Provide real-time travel intelligence.

Features:
- Weather-aware recommendations
- Rain alerts
- Best visiting hours
- Crowd predictions
- Peak-hour avoidance

Recommended Stack:
- OpenWeather API
- Historical traffic data
- Local event data
- Existing itinerary engine

---

# 9. SOCIAL TRAVEL FEATURES

Add social travel engagement.

Features:
- Follow travelers
- Public profiles
- Route sharing
- Travel stories
- Photos
- Reviews
- Activity feed

Recommended Stack:
- Existing User System
- Existing Media Storage
- Notification Service

---

# 10. ANALYTICS & INSIGHTS

Track:

- Most visited attractions
- Popular routes
- Narration usage
- Badge progression
- User engagement

Provide dashboards for:
- Users
- Admins

Recommended Stack:
- Existing Analytics Provider
- PostgreSQL Reporting Tables

---

# PERFORMANCE REQUIREMENTS

- Offline-first architecture
- Local caching
- Lazy loading
- Marker clustering
- Image optimization
- Pagination
- Background sync

Targets:
- Map load < 1 second
- Offline search < 500ms
- API response < 300ms

---

# SECURITY REQUIREMENTS

- Input validation
- API protection
- Rate limiting
- Secure offline storage
- Abuse protection for AI endpoints
- Existing authentication integration

Implement all features in a modular, production-ready, scalable manner while preserving all current functionality.