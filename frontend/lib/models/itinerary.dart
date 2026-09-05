class Itinerary {
  const Itinerary({
    required this.destination,
    required this.days,
    required this.totalPlaces,
    required this.generatedBy,
  });

  final String destination;
  final List<ItineraryDay> days;
  final int totalPlaces;
  final String generatedBy;

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      destination: json['destination'] as String? ?? '',
      days: (json['days'] as List<dynamic>? ?? [])
          .map((item) => ItineraryDay.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPlaces: json['totalPlaces'] as int? ?? 0,
      generatedBy: json['generatedBy'] as String? ?? 'rule-based',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'days': days.map((day) => day.toJson()).toList(),
      'totalPlaces': totalPlaces,
      'generatedBy': generatedBy,
    };
  }
}

class ItineraryDay {
  const ItineraryDay({
    required this.dayNumber,
    required this.places,
  });

  final int dayNumber;
  final List<ItineraryPlace> places;

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      dayNumber: json['dayNumber'] as int,
      places: (json['places'] as List<dynamic>)
          .map((item) => ItineraryPlace.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'places': places.map((place) => place.toJson()).toList(),
    };
  }
}

class ItineraryPlace {
  const ItineraryPlace({
    required this.placeId,
    required this.name,
    required this.category,
    required this.sequenceOrder,
    required this.estimatedVisitMinutes,
    required this.estimatedTravelMinutes,
    required this.travelDistanceKm,
    required this.openingTime,
    required this.closingTime,
    required this.latitude,
    required this.longitude,
  });

  final String placeId;
  final String name;
  final String category;
  final int sequenceOrder;
  final int estimatedVisitMinutes;
  final int estimatedTravelMinutes;
  final double travelDistanceKm;
  final String openingTime;
  final String closingTime;
  final double latitude;
  final double longitude;

  factory ItineraryPlace.fromJson(Map<String, dynamic> json) {
    return ItineraryPlace(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      sequenceOrder: json['sequenceOrder'] as int,
      estimatedVisitMinutes: json['estimatedVisitMinutes'] as int,
      estimatedTravelMinutes: json['estimatedTravelMinutes'] as int? ?? 0,
      travelDistanceKm: (json['travelDistanceKm'] as num?)?.toDouble() ?? 0,
      openingTime: json['openingTime'] as String? ?? '',
      closingTime: json['closingTime'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'category': category,
      'sequenceOrder': sequenceOrder,
      'estimatedVisitMinutes': estimatedVisitMinutes,
      'estimatedTravelMinutes': estimatedTravelMinutes,
      'travelDistanceKm': travelDistanceKm,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
