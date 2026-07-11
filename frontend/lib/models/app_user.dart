import 'package:clerk_auth/clerk_auth.dart' show User;

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.username,
  });

  final String id;
  final String email;
  final String username;

  String get displayName {
    if (username.trim().isNotEmpty) {
      return username.trim();
    }

    if (email.contains('@')) {
      return email.split('@').first;
    }

    return id;
  }

  factory AppUser.fromClerk(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      username: user.username ?? '',
    );
  }
}
