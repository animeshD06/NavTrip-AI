# Clerk Auth Verification

## Status

Local runtime verification was not completed in this environment because the Flutter SDK is not available on `PATH`, and Clerk dashboard credentials were not provided.

## Implemented checks

- Clerk bootstrap wired into the Flutter app
- Provider-backed auth state added
- Login and sign-up screens replaced with Clerk-backed forms
- Google sign-in flow added
- Logout path added
- Session restoration gate added at app start
- Protected route gating added for dashboard, itinerary, and map screens
- Android deep-link intent filters added
- iOS URL scheme added

## Not executed locally

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- Device or emulator sign-in flows
- Clerk dashboard account creation and verification
- Google OAuth round-trip
- Session restore after full app restart

## Blocking external dependencies

- Clerk publishable key not available in a populated `.env`
- Clerk dashboard setup and Native API status not verifiable from this repo alone
- Flutter SDK unavailable in the current shell session

## Remaining issues to verify in a real Clerk project

- Native API is enabled in Clerk Dashboard
- Email/password login succeeds
- Username/password login succeeds
- Email verification link flow returns to the app
- Google OAuth redirect returns to the app on Android and iOS
- Session survives a full restart
