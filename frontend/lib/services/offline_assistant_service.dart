import 'offline_cache_service.dart';

class OfflineAssistantService {
  const OfflineAssistantService(this._cache);

  final OfflineCacheService _cache;

  Future<Map<String, dynamic>> answer({
    required String city,
    required String query,
    String language = 'en-IN',
  }) async {
    final startedAt = DateTime.now();
    final places = await _cache.searchPlaces(
      city: city,
      query: query,
      language: language,
    );
    final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;

    if (places.isEmpty) {
      return {
        'answer':
            'No downloaded city-pack result matched this question yet.',
        'sources': <Map<String, dynamic>>[],
        'mode': 'offline-local-search',
        'elapsedMs': elapsedMs,
      };
    }

    final topPlace = places.first;

    return {
      'answer': '${topPlace.name}: ${topPlace.description}',
      'sources': places.take(5).map((place) {
        return {
          'placeId': place.id,
          'name': place.name,
          'category': place.category,
          'city': place.city,
        };
      }).toList(),
      'mode': 'offline-local-search',
      'elapsedMs': elapsedMs,
    };
  }
}
