import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _authStateSubscription = _authService.authStateChanges.listen(_handleAuthStateChanged);
    _handleAuthStateChanged(_authService.currentUser);
  }

  final AuthService _authService = AuthService();
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

  Future<void> restoreSession() async {
    _syncFromUser(_authService.currentUser);
    await _authService.restoreSession();
    _syncFromUser(_authService.currentUser);
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
    _isReady = true;
    _currentUser = user == null ? null : AppUser.fromFirebase(user);
    _verificationMessage = user != null && user.emailVerified == false
        ? 'Check your email to verify your account.'
        : null;

    if (_currentUser != null) {
      _errorMessage = null;
    }

    notifyListeners();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _syncFromUser(_authService.currentUser);
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
    if (error is firebase_auth.FirebaseAuthException) {
      final code = error.code.toLowerCase();
      final message = (error.message ?? '').trim();

      switch (code) {
        case 'email-already-in-use':
          return 'That email is already in use.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'weak-password':
          return 'Use a stronger password.';
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

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
