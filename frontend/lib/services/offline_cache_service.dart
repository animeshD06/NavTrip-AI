import '../models/tourist_place.dart';

class OfflineGuidePack {
  const OfflineGuidePack({
    required this.city,
    required this.version,
    required this.language,
    required this.checksum,
    required this.places,
    required this.narrations,
    required this.knowledgeChunks,
    required this.cachedAt,
  });

  final String city;
  final String version;
  final String language;
  final String checksum;
  final List<TouristPlace> places;
  final List<Map<String, dynamic>> narrations;
  final List<Map<String, dynamic>> knowledgeChunks;
  final DateTime cachedAt;
}

class OfflineCacheService {
  final Map<String, OfflineGuidePack> _guidePacks = {};
  final List<Map<String, dynamic>> _pendingAnalyticsEvents = [];

  String _key(String city, String language) {
    return '${city.trim().toLowerCase()}:$language';
  }

  Future<void> saveGuidePack(Map<String, dynamic> manifest) async {
    final city = manifest['city'] as String;
    final language = manifest['language'] as String? ?? 'en-IN';
    final places = (manifest['places'] as List<dynamic>? ?? [])
        .map((item) => TouristPlace.fromJson(item as Map<String, dynamic>))
        .toList();

    _guidePacks[_key(city, language)] = OfflineGuidePack(
      city: city,
      version: manifest['version'] as String? ?? '1.0.0',
      language: language,
      checksum: manifest['checksum'] as String? ?? '',
      places: places,
      narrations: (manifest['narrations'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>(),
      knowledgeChunks: (manifest['knowledgeChunks'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>(),
      cachedAt: DateTime.now(),
    );
  }

  Future<OfflineGuidePack?> getGuidePack(
    String city, {
    String language = 'en-IN',
  }) async {
    return _guidePacks[_key(city, language)];
  }

  Future<List<TouristPlace>> searchPlaces({
    required String city,
    required String query,
    String language = 'en-IN',
  }) async {
    final pack = await getGuidePack(city, language: language);

    if (pack == null) {
      return const [];
    }

    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return pack.places;
    }

    return pack.places.where((place) {
      final text =
          '${place.name} ${place.category} ${place.description} ${place.city}'
              .toLowerCase();
      return text.contains(normalizedQuery);
    }).toList();
  }

  Future<String?> narrationFor({
    required String city,
    required String placeId,
    required String mode,
    String language = 'en-IN',
  }) async {
    final pack = await getGuidePack(city, language: language);

    if (pack == null) {
      return null;
    }

    final narration = pack.narrations.cast<Map<String, dynamic>?>().firstWhere(
          (item) =>
              item?['placeId'] == placeId &&
              item?['mode'] == mode &&
              item?['language'] == language,
          orElse: () => null,
        );

    return narration?['content'] as String?;
  }

  void queueAnalyticsEvent(Map<String, dynamic> event) {
    _pendingAnalyticsEvents.add(event);
  }

  List<Map<String, dynamic>> drainAnalyticsEvents() {
    final events = List<Map<String, dynamic>>.from(_pendingAnalyticsEvents);
    _pendingAnalyticsEvents.clear();
    return events;
  }
}
