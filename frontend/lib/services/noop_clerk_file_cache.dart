import 'dart:io';

import 'package:clerk_flutter/src/utils/clerk_file_cache.dart';

class NoOpClerkFileCache implements ClerkFileCache {
  const NoOpClerkFileCache();

  @override
  Future<void> initialize() async {}

  @override
  void terminate() {}

  @override
  Stream<File> stream(
    Uri uri, {
    Duration ttl = ClerkFileCache.defaultTTL,
    Map<String, String>? headers,
  }) async* {}
}
