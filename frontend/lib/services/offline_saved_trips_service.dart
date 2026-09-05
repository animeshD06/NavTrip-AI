import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/itinerary.dart';

class CachedTrip {
  const CachedTrip({
    required this.destination,
    required this.category,
    required this.days,
    required this.savedAt,
    required this.itinerary,
  });

  final String destination;
  final String category;
  final int days;
  final DateTime savedAt;
  final Itinerary itinerary;

  factory CachedTrip.fromJson(Map<String, dynamic> json) {
    return CachedTrip(
      destination: json['destination'] as String? ?? '',
      category: json['category'] as String? ?? '',
      days: json['days'] as int? ?? 0,
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      itinerary:
          Itinerary.fromJson(json['itinerary'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'category': category,
      'days': days,
      'savedAt': savedAt.toIso8601String(),
      'itinerary': itinerary.toJson(),
    };
  }
}

class OfflineSavedTripsService {
  static const _tripsKey = 'navtrip.savedTrips.v1';
  static const _maxTrips = 12;

  Future<List<CachedTrip>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_tripsKey);
    if (encoded == null || encoded.isEmpty) {
      return [];
    }

    final data = jsonDecode(encoded) as List<dynamic>;
    return data
        .map((item) => CachedTrip.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((first, second) => second.savedAt.compareTo(first.savedAt));
  }

  Future<CachedTrip?> loadLatestTrip() async {
    final trips = await loadTrips();
    return trips.isEmpty ? null : trips.first;
  }

  Future<void> saveTrip({
    required String destination,
    required String category,
    required int days,
    required Itinerary itinerary,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = await loadTrips();
    final cacheKey = _cacheKey(destination, category, days);
    final nextTrips = [
      CachedTrip(
        destination: destination,
        category: category,
        days: days,
        savedAt: DateTime.now(),
        itinerary: itinerary,
      ),
      ...trips.where((trip) =>
          _cacheKey(trip.destination, trip.category, trip.days) != cacheKey),
    ].take(_maxTrips).map((trip) => trip.toJson()).toList();

    await prefs.setString(_tripsKey, jsonEncode(nextTrips));
  }

  String _cacheKey(String destination, String category, int days) {
    return '${destination.trim().toLowerCase()}|${category.trim().toLowerCase()}|$days';
  }
}
