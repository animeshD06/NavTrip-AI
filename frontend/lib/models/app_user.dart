import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.emailVerified,
  });

  final String id;
  final String email;
  final String username;
  final bool emailVerified;

  String get displayName {
    if (username.trim().isNotEmpty) {
      return username.trim();
    }

    if (email.contains('@')) {
      return email.split('@').first;
    }

    return id;
  }

  factory AppUser.fromFirebase(firebase_auth.User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      username: user.displayName ?? '',
      emailVerified: user.emailVerified,
    );
  }
}
