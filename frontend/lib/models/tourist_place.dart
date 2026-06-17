class TouristPlace {
  const TouristPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.city,
    required this.state,
    required this.rating,
    required this.openingTime,
    required this.closingTime,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final String description;
  final String city;
  final String state;
  final double rating;
  final String openingTime;
  final String closingTime;
  final double? distanceKm;

  factory TouristPlace.fromJson(Map<String, dynamic> json) {
    return TouristPlace(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      city: json['city'] as String,
      state: json['state'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      openingTime: json['openingTime'] as String? ?? '',
      closingTime: json['closingTime'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }
}
