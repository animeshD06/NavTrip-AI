# NavTrip AI Frontend

Flutter app for the AI Tourist Map and Smart Travel Planner.

## Tooling

This repo currently uses a local Flutter SDK at `../tools/flutter`.

```bash
cd frontend
..\tools\flutter\bin\flutter.bat pub get
..\tools\flutter\bin\flutter.bat run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:4000/api --dart-define=CLERK_SIGN_IN_URL=https://your-clerk-sign-in-url --dart-define=CLERK_SIGN_IN_FALLBACK_REDIRECT_URL=/ --dart-define=CLERK_SIGN_UP_FALLBACK_REDIRECT_URL=/
```

For Android emulator, use:

```bash
..\tools\flutter\bin\flutter.bat run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api --dart-define=CLERK_SIGN_IN_URL=https://your-clerk-sign-in-url --dart-define=CLERK_SIGN_IN_FALLBACK_REDIRECT_URL=/ --dart-define=CLERK_SIGN_UP_FALLBACK_REDIRECT_URL=/
```

The `/login` screen now launches Clerk from the existing Flutter UI. Set `CLERK_SIGN_IN_URL` to the Clerk-hosted sign-in page or the auth URL you want users to open from the app.

Validation:

```bash
..\tools\flutter\bin\flutter.bat analyze
..\tools\flutter\bin\flutter.bat test
```
