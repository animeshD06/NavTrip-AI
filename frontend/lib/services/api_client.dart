import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../models/itinerary.dart';
import '../models/tourist_place.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );

  final Dio _dio;

  static String get baseUrlLabel => ApiConfig.baseUrl;

  Future<Map<String, dynamic>> fetchHealth() async {
    final response = await _dio.get<Map<String, dynamic>>('/health');
    return response.data ?? <String, dynamic>{};
  }

  Future<List<TouristPlace>> fetchPlaces({
    String? city,
    String? category,
    String? search,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/places',
      queryParameters: {
        if (city != null && city.isNotEmpty) 'city': city,
        if (category != null && category.isNotEmpty) 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => TouristPlace.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Itinerary> generateItinerary({
    required String destination,
    required int days,
    required String category,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/itineraries/generate',
      data: {
        'destination': destination,
        'days': days,
        'category': category,
      },
    );

    return Itinerary.fromJson(response.data?['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> fetchNarration({
    required String placeId,
    String mode = 'medium',
    String language = 'en-IN',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/narrations/$placeId',
      queryParameters: {
        'mode': mode,
        'language': language,
      },
    );

    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  Future<List<Map<String, dynamic>>> fetchGuidePacks({
    String? city,
    String language = 'en-IN',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/guide-packs',
      queryParameters: {
        if (city != null && city.isNotEmpty) 'city': city,
        'language': language,
      },
    );

    return (response.data?['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> downloadGuidePackManifest({
    required String city,
    String language = 'en-IN',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/guide-packs/$city/download-manifest',
      data: {'language': language},
    );

    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  Future<List<Map<String, dynamic>>> fetchHiddenGems({
    String? city,
    double? latitude,
    double? longitude,
    List<String> interests = const [],
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/recommendations/hidden-gems',
      queryParameters: {
        if (city != null && city.isNotEmpty) 'city': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (interests.isNotEmpty) 'interests': interests.join(','),
      },
    );

    return (response.data?['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> queryAssistant({
    required String query,
    String? city,
    double? latitude,
    double? longitude,
    bool offlinePreferred = true,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/assistant/query',
      data: {
        'query': query,
        if (city != null && city.isNotEmpty) 'city': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'offlinePreferred': offlinePreferred,
      },
    );

    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> optimizeItinerary({
    required String destination,
    required int days,
    required List<String> interests,
    required String travelStyle,
    required int groupSize,
    double? budget,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/itineraries/optimize',
      data: {
        'destination': destination,
        'days': days,
        'interests': interests,
        'travelStyle': travelStyle,
        'groupSize': groupSize,
        if (budget != null) 'budget': budget,
      },
    );

    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> fetchWeatherCrowdInsights({
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/weather-crowd/insights',
      queryParameters: {
        if (city != null && city.isNotEmpty) 'city': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );

    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  Future<void> recordAnalyticsEvent({
    required String feature,
    required String eventName,
    String? sessionId,
    String? entityType,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/analytics/events',
      data: {
        'feature': feature,
        'eventName': eventName,
        if (sessionId != null) 'sessionId': sessionId,
        if (entityType != null) 'entityType': entityType,
        if (entityId != null) 'entityId': entityId,
        'metadata': metadata,
      },
    );
  }
}
