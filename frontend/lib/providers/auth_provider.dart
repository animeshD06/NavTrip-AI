import 'package:clerk_auth/clerk_auth.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  ClerkAuthState? _authState;
  AppUser? _currentUser;
  bool _isBusy = false;
  bool _isReady = false;
  String? _errorMessage;
  String? _verificationMessage;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isBusy => _isBusy || (_authState?.isSigningIn ?? false) || (_authState?.isSigningUp ?? false);
  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;
  String? get verificationMessage => _verificationMessage;

  void attach(ClerkAuthState authState) {
    if (identical(_authState, authState)) {
      _syncFromAuth();
      return;
    }

    _authState?.removeListener(_syncFromAuth);
    _authState = authState;
    _authService.attach(authState);
    _authState?.addListener(_syncFromAuth);
    _syncFromAuth();
  }

  Future<void> restoreSession() async {
    _syncFromAuth();
    await _authService.restoreSession();
    _syncFromAuth();
  }

  Future<void> signIn({
    required String identifier,
    required String password,
  }) {
    return _runAction(() => _authService.signIn(identifier: identifier, password: password));
  }

  Future<void> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) {
    return _runAction(() => _authService.signUp(
          email: email,
          username: username,
          password: password,
          confirmPassword: confirmPassword,
        ));
  }

  Future<void> signInWithGoogle() {
    return _runAction(_authService.signInWithGoogle);
  }

  Future<void> signOut() {
    return _runAction(_authService.signOut);
  }

  Future<void> handleDeepLink(Uri uri) {
    return _runAction(() => _authService.handleDeepLink(uri));
  }

  void clearMessages() {
    _errorMessage = null;
    _verificationMessage = null;
    notifyListeners();
  }

  void _syncFromAuth() {
    final authState = _authState;
    _isReady = authState != null && !authState.isNotAvailable;
    _currentUser = _authService.getCurrentUser();
    _verificationMessage = _needsVerification ? 'Check your email to finish verifying your account.' : null;

    if (_currentUser != null) {
      _errorMessage = null;
    }

    notifyListeners();
  }

  bool get _needsVerification =>
      _authState?.signUp?.verifications.values.any((v) => v.status.isVerified == false) == true &&
      _currentUser == null;

  Future<void> _runAction(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _syncFromAuth();
    } catch (error) {
      _errorMessage = _friendlyMessage(error);
      notifyListeners();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  String _friendlyMessage(Object error) {
    if (error is ClerkError) {
      final message = error.message.trim();
      final lower = message.toLowerCase();

      if (lower.contains('password') && (lower.contains('incorrect') || lower.contains('invalid'))) {
        return 'That password is not correct.';
      }

      if ((lower.contains('email') || lower.contains('identifier') || lower.contains('username')) &&
          lower.contains('already')) {
        if (lower.contains('username')) {
          return 'That username is already in use.';
        }
        if (lower.contains('email')) {
          return 'That email is already in use.';
        }
        return 'That account already exists.';
      }

      if (lower.contains('not found') || lower.contains('could not find') || lower.contains('unknown')) {
        return 'We could not find an account for that login.';
      }

      if (lower.contains('oauth') || lower.contains('google') || lower.contains('social')) {
        return 'Google sign-in could not be completed.';
      }

      if (lower.contains('network') || lower.contains('socket') || lower.contains('timeout')) {
        return 'A network error interrupted authentication. Try again.';
      }

      return message;
    }

    final message = error.toString();
    final lower = message.toLowerCase();

    if (lower.contains('network') || lower.contains('socket') || lower.contains('timeout')) {
      return 'A network error interrupted authentication. Try again.';
    }

    return 'Authentication failed. Please try again.';
  }

  @override
  void dispose() {
    _authState?.removeListener(_syncFromAuth);
    super.dispose();
  }
}

