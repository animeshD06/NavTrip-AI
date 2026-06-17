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
}
