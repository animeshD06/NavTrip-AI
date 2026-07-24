import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {
  AuthService();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  firebase_auth.User? get currentUser => _auth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<firebase_auth.UserCredential> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      throw firebase_auth.FirebaseAuthException(
        code: 'password-mismatch',
        message: 'Password and confirmation must match.',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      final displayName = username.trim();
      if (displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      await user.sendEmailVerification();
      await user.reload();
    }

    return credential;
  }

  Future<firebase_auth.UserCredential> signIn({
    required String identifier,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: identifier.trim(),
      password: password,
    );
  }

  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: <String>['email', 'profile']);
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'popup-closed-by-user',
        message: 'Google sign-in was cancelled.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn().signOut(),
    ]);
  }

  Future<void> handleDeepLink(Uri uri) async {
    // Firebase auth does not require custom deep-link parsing for this app.
  }

  Future<void> restoreSession() async {
    await currentUser?.reload();
  }
}


