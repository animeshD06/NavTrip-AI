import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static bool get hasConfig {
    return _required('FIREBASE_API_KEY').isNotEmpty &&
        _required('FIREBASE_APP_ID').isNotEmpty &&
        _required('FIREBASE_MESSAGING_SENDER_ID').isNotEmpty &&
        _required('FIREBASE_PROJECT_ID').isNotEmpty;
  }

  static FirebaseOptions get options {
    return FirebaseOptions(
      apiKey: _required('FIREBASE_API_KEY'),
      appId: _required('FIREBASE_APP_ID'),
      messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
      projectId: _required('FIREBASE_PROJECT_ID'),
      authDomain: _optional('FIREBASE_AUTH_DOMAIN'),
      databaseURL: _optional('FIREBASE_DATABASE_URL'),
      storageBucket: _optional('FIREBASE_STORAGE_BUCKET'),
      measurementId: _optional('FIREBASE_MEASUREMENT_ID'),
      trackingId: _optional('FIREBASE_TRACKING_ID'),
      deepLinkURLScheme: _optional('FIREBASE_DEEP_LINK_URL_SCHEME'),
      androidClientId: _optional('FIREBASE_ANDROID_CLIENT_ID'),
      iosClientId: _optional('FIREBASE_IOS_CLIENT_ID'),
      iosBundleId: _optional('FIREBASE_IOS_BUNDLE_ID'),
      appGroupId: _optional('FIREBASE_APP_GROUP_ID'),
    );
  }

  static String _required(String key) {
    final value = dotenv.env[key]?.trim() ?? '';
    if (value.isEmpty) {
      throw StateError('$key is missing. Add it to frontend/.env.');
    }
    return value;
  }

  static String? _optional(String key) {
    final value = dotenv.env[key]?.trim() ?? '';
    return value.isEmpty ? null : value;
  }
}


