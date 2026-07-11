import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'package:clerk_auth/clerk_auth.dart';

class AuthConfig {
  AuthConfig._();

  static const _redirectScheme = 'navtripai';
  static const _redirectHost = 'auth';
  static const _oauthRedirectPath = '/oauth';
  static const _emailVerificationRedirectPath = '/email-link';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static bool get hasPublishableKey => dotenv.env['CLERK_PUBLISHABLE_KEY']?.trim().isNotEmpty ?? false;

  static String get publishableKey {
    final value = dotenv.env['CLERK_PUBLISHABLE_KEY']?.trim() ?? '';
    if (value.isEmpty) {
      throw StateError('CLERK_PUBLISHABLE_KEY is missing. Add it to frontend/.env.');
    }
    return value;
  }

  static Uri get oauthRedirectUri => Uri(
        scheme: _redirectScheme,
        host: _redirectHost,
        path: _oauthRedirectPath,
      );

  static Uri get emailVerificationRedirectUri => Uri(
        scheme: _redirectScheme,
        host: _redirectHost,
        path: _emailVerificationRedirectPath,
      );

  static Uri? redirectUriGenerator(BuildContext context, Strategy strategy) {
    if (strategy.isOauth) {
      return oauthRedirectUri;
    }

    if (strategy.isEmailLink) {
      return emailVerificationRedirectUri;
    }

    return null;
  }

  static Future<Uri?> filterDeepLink(Uri uri) async {
    final allowedPaths = <String>{_oauthRedirectPath, _emailVerificationRedirectPath};
    if (uri.scheme == _redirectScheme && uri.host == _redirectHost && allowedPaths.contains(uri.path)) {
      return uri;
    }

    return null;
  }

  static Stream<Uri?> deepLinkStream() {
    return AppLinks().uriLinkStream.asyncMap(filterDeepLink);
  }
}
