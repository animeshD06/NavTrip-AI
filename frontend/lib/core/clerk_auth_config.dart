class ClerkAuthConfig {
  ClerkAuthConfig._();

  static const signInUrl = String.fromEnvironment(
    'CLERK_SIGN_IN_URL',
    defaultValue: '',
  );

  static const signInFallbackRedirectUrl = String.fromEnvironment(
    'CLERK_SIGN_IN_FALLBACK_REDIRECT_URL',
    defaultValue: '',
  );

  static const signUpFallbackRedirectUrl = String.fromEnvironment(
    'CLERK_SIGN_UP_FALLBACK_REDIRECT_URL',
    defaultValue: '',
  );

  static bool get hasSignInUrl => signInUrl.isNotEmpty;
}
