# Current Status - Firebase Auth Migration

Date: 2026-07-14

## What We Changed

- Removed Clerk auth from the frontend and backend.
- Switched the Flutter app to Firebase Auth.
- Added Firebase initialization through `frontend/lib/config/firebase_config.dart` and `.env` values.
- Kept the app analyzable and bootable on Flutter Web.

## Current Auth Setup

### Frontend

- `frontend/lib/providers/auth_provider.dart` now uses `FirebaseAuth` state changes.
- `frontend/lib/services/auth_service.dart` handles:
  - email/password sign-up
  - email/password sign-in
  - Google sign-in
  - sign-out
- `frontend/lib/widgets/auth_guard.dart` redirects based on auth state and email verification.
- `frontend/lib/screens/login_screen.dart` and `frontend/lib/screens/signup_screen.dart` now use Firebase language and flow.
- `frontend/.env` contains the Firebase web config values from the Firebase console.

### Backend

- Clerk middleware and Clerk dependency were removed.
- Backend auth is no longer tied to Clerk.

## Important Runtime Fix

- The web app was throwing an initial route error for `/login` during startup.
- That was fixed by adding bootstrap routes in `frontend/lib/main.dart` so `/login`, `/signup`, `/dashboard`, `/trip-details`, and `/trip-map` exist even before Firebase finishes booting.

## Validation

- `frontend` passes `flutter analyze`.
- Repo search no longer finds Clerk references in `frontend`, `backend`, or `docs`.

## Firebase Values Present In `.env`

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_MEASUREMENT_ID`

## Notes To Remember

- The Flutter app reads Firebase config from `.env`, not from the JavaScript `initializeApp()` snippet.
- Google sign-in still depends on Firebase console/provider setup and platform-specific client IDs where needed.
- The dashboard route currently resolves through the existing home-style route flow while the app structure stays stable.

## Next Good Steps

- Wire up Firebase Google sign-in credentials for each platform.
- Add a proper post-verification screen or resend-verification flow.
- Run the app in browser and confirm sign-up / sign-in end-to-end.
