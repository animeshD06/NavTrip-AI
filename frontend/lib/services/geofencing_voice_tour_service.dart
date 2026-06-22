import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/tourist_place.dart';
import 'voice_narration_service.dart';

class VoiceTourSettings {
  const VoiceTourSettings({
    this.enabled = false,
    this.radiusMeters = 100,
    this.cooldown = const Duration(minutes: 20),
    this.mode = NarrationMode.medium,
    this.language = 'en-IN',
  });

  final bool enabled;
  final int radiusMeters;
  final Duration cooldown;
  final NarrationMode mode;
  final String language;

  VoiceTourSettings copyWith({
    bool? enabled,
    int? radiusMeters,
    Duration? cooldown,
    NarrationMode? mode,
    String? language,
  }) {
    return VoiceTourSettings(
      enabled: enabled ?? this.enabled,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      cooldown: cooldown ?? this.cooldown,
      mode: mode ?? this.mode,
      language: language ?? this.language,
    );
  }
}

class GeofencingVoiceTourService {
  GeofencingVoiceTourService(this._voiceNarrationService);

  final VoiceNarrationService _voiceNarrationService;
  final Map<String, DateTime> _lastNarratedAt = {};
  StreamSubscription<Position>? _subscription;
  VoiceTourSettings _settings = const VoiceTourSettings();
  List<TouristPlace> _places = const [];

  VoiceTourSettings get settings => _settings;

  void updatePlaces(List<TouristPlace> places) {
    _places = List<TouristPlace>.from(places);
  }

  Future<void> updateSettings(VoiceTourSettings settings) async {
    _settings = settings;

    if (!_settings.enabled) {
      await stop();
      return;
    }

    await start();
  }

  Future<void> start() async {
    if (_subscription != null || !_settings.enabled) {
      return;
    }

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 25,
      ),
    ).listen(_handlePosition);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stop();
  }

  void _handlePosition(Position position) {
    if (!_settings.enabled || _places.isEmpty) {
      return;
    }

    TouristPlace? nearestPlace;
    var nearestDistance = double.infinity;

    for (final place in _places) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        place.latitude,
        place.longitude,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestPlace = place;
      }
    }

    if (nearestPlace == null || nearestDistance > _settings.radiusMeters) {
      return;
    }

    final lastNarratedAt = _lastNarratedAt[nearestPlace.id];
    final now = DateTime.now();

    if (lastNarratedAt != null &&
        now.difference(lastNarratedAt) < _settings.cooldown) {
      return;
    }

    _lastNarratedAt[nearestPlace.id] = now;
    _voiceNarrationService.speakPlace(
      nearestPlace,
      mode: _settings.mode,
      language: _settings.language,
    );
  }
}
