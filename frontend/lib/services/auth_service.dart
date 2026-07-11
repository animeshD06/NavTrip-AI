import 'package:clerk_auth/clerk_auth.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

import '../config/auth_config.dart' as app_auth;
import '../models/app_user.dart';

class AuthService {
  ClerkAuthState? _authState;

  void attach(ClerkAuthState authState) {
    _authState = authState;
  }

  ClerkAuthState get _state {
    final authState = _authState;
    if (authState == null) {
      throw StateError('AuthService has not been attached to ClerkAuthState yet.');
    }
    return authState;
  }

  AppUser? getCurrentUser() {
    final user = _authState?.user;
    if (user == null) {
      return null;
    }

    return AppUser.fromClerk(user);
  }

  Future<void> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) {
    return _state.attemptSignUp(
      strategy: Strategy.password,
      emailAddress: email.trim(),
      username: username.trim(),
      password: password,
      passwordConfirmation: confirmPassword,
      redirectUrl: app_auth.AuthConfig.emailVerificationRedirectUri.toString(),
    );
  }

  Future<void> signIn({
    required String identifier,
    required String password,
  }) {
    return _state.attemptSignIn(
      strategy: Strategy.password,
      identifier: identifier.trim(),
      password: password,
    );
  }

  Future<void> signInWithGoogle() {
    return _state.oauthSignIn(
      strategy: Strategy.oauthGoogle,
      redirect: app_auth.AuthConfig.oauthRedirectUri,
    );
  }

  Future<void> signOut() {
    return _state.signOut();
  }

  Future<void> handleDeepLink(Uri uri) async {
    await _state.parseDeepLink(uri);
  }

  Future<void> restoreSession() async {
    getCurrentUser();
  }
}


