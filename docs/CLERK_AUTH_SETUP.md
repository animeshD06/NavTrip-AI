# Clerk Auth Setup

## What was added

NavTrip AI now boots through Clerk using the official Flutter SDK and a local auth provider layer.

## Environment

Create `frontend/.env` with:

```env
CLERK_PUBLISHABLE_KEY=pk_...
```

The app reads this value through `lib/config/auth_config.dart`.

## Clerk Dashboard setup

Enable the following in your Clerk application:

- Email authentication
- Password authentication
- Username authentication
- Google OAuth
- Native API support for mobile SDK flows

Native API must be enabled for mobile authentication flows to work correctly with the Flutter SDK. If it is not enabled, Clerk mobile auth will not complete reliably.

## Google OAuth setup

In Clerk Dashboard:

1. Add Google as a social connection.
2. Configure the Google OAuth client credentials.
3. Make sure the redirect flow is allowed for your application.
4. Confirm the Google connection is enabled for both sign-in and sign-up.

For Android, also register the app signing SHA-1 fingerprints in Google Cloud for the OAuth client that Clerk uses.

## Redirect URIs

This app uses the custom scheme:

- `navtripai://auth/oauth`
- `navtripai://auth/email-link`

These are generated in `lib/config/auth_config.dart` and handled by Clerk deep-link parsing.

## Android configuration

The app manifest now includes:

- `android.permission.INTERNET`
- intent filters for `navtripai://auth/oauth`
- intent filters for `navtripai://auth/email-link`

If Google OAuth fails on Android, confirm:

- The correct SHA-1 certificate fingerprint is registered in Google Cloud.
- The Clerk Google connection is enabled.
- The package name and OAuth client IDs match the build variant.

## iOS configuration

`ios/Runner/Info.plist` now registers the `navtripai` URL scheme.

If iOS OAuth returns to Safari instead of the app, confirm:

- The `navtripai` URL scheme is present in the app target.
- Clerk is redirecting to one of the two supported paths above.
- The app was rebuilt after changing the plist.

## Auth flow

- Unauthenticated users can use `/login` and `/signup`.
- Protected routes `/dashboard`, `/trip-details`, and `/trip-map` are gated.
- Signed-in users are routed back into the app and restored on restart.
- The dashboard profile menu shows Clerk user ID, username, and email.

## Testing checklist

Use these manual tests after configuring Clerk:

1. Sign up with email, username, and password.
2. Sign out.
3. Sign in with username + password.
4. Sign out.
5. Sign in with email + password.
6. Sign in with Google.
7. Restart the app and confirm the session is restored.

## Notes

If Clerk email verification is enabled, the app will surface the verification state and rely on the configured redirect link to complete the flow.
