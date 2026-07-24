# Frontend Runtime Issues

This note captures the problems shown in the pasted browser log and the direct fixes for the current Firebase-based frontend.

## 1) `setState() or markNeedsBuild() called during build`

### What the log says

The old log showed repeated Flutter framework errors while `AuthProvider` was syncing auth state.

### Why this can happen

This usually means a notifier is triggering `notifyListeners()` while Flutter is still building the widget tree.

In this app, the auth provider now listens to Firebase auth changes and syncs after the app has initialized.

Relevant code:

- [`frontend/lib/providers/auth_provider.dart`](C:/Users/hp/NavTrip%20AI/frontend/lib/providers/auth_provider.dart)
- [`frontend/lib/main.dart`](C:/Users/hp/NavTrip%20AI/frontend/lib/main.dart)

### How to fix it

1. Keep auth state sync inside the provider, not in a widget build callback.
2. Avoid firing `notifyListeners()` synchronously from startup navigation code.
3. Only update auth-related messages when the state actually changes.

## 2) Firebase auth configuration errors

### What the log says

If Firebase is not configured, the app now stops at startup and shows a config screen instead of crashing later in the auth flow.

### Why this can happen

Common causes include:

- missing Firebase values in `frontend/.env`
- the wrong Firebase project settings copied into the env file
- email/password or Google sign-in not enabled in the Firebase console
- the web OAuth domain not being authorized for Google sign-in

Relevant code:

- [`frontend/lib/config/firebase_config.dart`](C:/Users/hp/NavTrip%20AI/frontend/lib/config/firebase_config.dart)
- [`frontend/lib/services/auth_service.dart`](C:/Users/hp/NavTrip%20AI/frontend/lib/services/auth_service.dart)
- [`frontend/.env`](C:/Users/hp/NavTrip%20AI/frontend/.env)

### How to fix it

1. Fill in the `FIREBASE_*` values in `frontend/.env`.
2. Enable Email/Password sign-in in Firebase Authentication.
3. Enable Google sign-in if you plan to use the Google button.
4. Make sure the web app domain is authorized in Firebase.
5. Rebuild the app after changing Firebase config.

### Safer implementation approach

- Show a dedicated startup screen when Firebase config is missing.
- Surface `FirebaseAuthException` messages in dev builds.
- Keep the login form aligned with the enabled Firebase sign-in methods.

## 3) Why repeated frames still appear in the console

### What the log says

Repeated frames usually mean one root issue is being re-reported during rebuilds or auth state updates.

### What to do

1. Fix the first startup or auth error, then re-run the app.
2. Clear browser storage if the app is replaying stale auth state.
3. Re-test from a clean browser tab or incognito window.

## Recommended fix order

1. Confirm Firebase config values are present.
2. Verify the auth provider is only syncing state from Firebase listeners.
3. Re-test sign-in and sign-up after the app boots cleanly.

## Quick checklist

- [ ] Keep one consistent route map available at app startup
- [ ] Avoid synchronous `notifyListeners()` during widget build
- [ ] Confirm Firebase env values in `frontend/.env`
- [ ] Confirm Firebase Authentication sign-in method settings
- [ ] Retest in a fresh browser session
