import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({bool enabled = true}) : _enabled = enabled {
    if (!_enabled) {
      _isReady = true;
      _errorMessage = 'Firebase auth is not configured for this build.';
      return;
    }

    _authService = AuthService();
    _authStateSubscription =
        _authService!.authStateChanges.listen(_handleAuthStateChanged);
    _handleAuthStateChanged(_authService!.currentUser);

    // Safety fallback: if auth state hasn't resolved after 5s, force ready
    // so the app doesn't hang on an infinite loading spinner.
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isReady) {
        debugPrint('[STARTUP] AuthProvider: 5s fallback fired — forcing ready');
        _isReady = true;
        notifyListeners();
      }
    });
  }

  final bool _enabled;
  AuthService? _authService;
  StreamSubscription<firebase_auth.User?>? _authStateSubscription;

  AppUser? _currentUser;
  bool _isBusy = false;
  bool _isReady = false;
  String? _errorMessage;
  String? _verificationMessage;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isBusy => _isBusy;
  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;
  String? get verificationMessage => _verificationMessage;
  bool get needsVerification => _currentUser != null && _currentUser!.emailVerified == false;

  Future<void> signIn({
    required String identifier,
    required String password,
  }) {
    return _runAction(
      () => _requireAuthService().signIn(
        identifier: identifier,
        password: password,
      ),
    );
  }

  Future<void> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) {
    return _runAction(() => _requireAuthService().signUp(
          email: email,
          username: username,
          password: password,
          confirmPassword: confirmPassword,
        ));
  }

  Future<void> signInWithGoogle() {
    return _runAction(_requireAuthService().signInWithGoogle);
  }

  Future<void> signOut() {
    return _runAction(_requireAuthService().signOut);
  }

  Future<void> handleDeepLink(Uri uri) {
    return _runAction(() => _requireAuthService().handleDeepLink(uri));
  }

  Future<void> restoreSession() async {
    if (!_enabled) {
      _isReady = true;
      notifyListeners();
      return;
    }

    final authService = _requireAuthService();
    _syncFromUser(authService.currentUser);
    await authService.restoreSession();
    _syncFromUser(authService.currentUser);
  }

  void clearMessages() {
    _errorMessage = null;
    _verificationMessage = null;
    notifyListeners();
  }

  void _handleAuthStateChanged(firebase_auth.User? user) {
    _syncFromUser(user);
  }

  void _syncFromUser(firebase_auth.User? user) {
    final wasReady = _isReady;
    _isReady = true;
    _currentUser = user == null ? null : AppUser.fromFirebase(user);
    _verificationMessage = user != null && user.emailVerified == false
        ? 'Check your email to verify your account.'
        : null;

    if (_currentUser != null) {
      _errorMessage = null;
    }

    if (!wasReady) {
      debugPrint('[STARTUP] AuthProvider: auth state resolved — '
          'user=${user?.uid ?? 'null'}');
    }

    notifyListeners();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _syncFromUser(_requireAuthService().currentUser);
    } on firebase_auth.FirebaseAuthException catch (error) {
      _errorMessage = _friendlyMessage(error);
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyMessage(error);
      notifyListeners();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  String _friendlyMessage(Object error) {
    if (error is StateError) {
      return error.message;
    }

    if (error is firebase_auth.FirebaseAuthException) {
      final rawCode = error.code.toLowerCase();
      final code = rawCode.startsWith('auth/') ? rawCode.substring(5) : rawCode;
      final message = (error.message ?? '').trim();

      switch (code) {
        case 'email-already-in-use':
          return 'That email is already in use.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'weak-password':
          return 'Use a stronger password (at least 6 characters).';
        case 'user-not-found':
          return 'We could not find an account for that email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'That email or password is not correct.';
        case 'network-request-failed':
          return 'A network error interrupted authentication. Try again.';
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
          return 'Google sign-in was cancelled.';
        case 'popup-blocked':
          return 'Sign-in popup was blocked by your browser. Please allow popups for this site.';
        case 'operation-not-allowed':
          return 'This sign-in provider is not enabled in Firebase Console.';
        case 'unauthorized-domain':
          return 'This domain is not authorized in Firebase Console.';
        case 'account-exists-with-different-credential':
          return 'That account already exists with a different sign-in method.';
        default:
          return message.isNotEmpty ? message : 'Authentication failed. Please try again.';
      }
    }

    final message = error.toString();
    final lower = message.toLowerCase();

    if (lower.contains('network') || lower.contains('socket') || lower.contains('timeout')) {
      return 'A network error interrupted authentication. Try again.';
    }

    return 'Authentication failed. Please try again.';
  }

  AuthService _requireAuthService() {
    final authService = _authService;
    if (_enabled && authService != null) {
      return authService;
    }

    throw StateError('Firebase auth is not configured for this build.');
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
