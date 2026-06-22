import 'package:flutter/foundation.dart';

import '../models/tourist_place.dart';

class ArExplorationResult {
  const ArExplorationResult({
    required this.supported,
    required this.message,
    this.nearestPlace,
  });

  final bool supported;
  final String message;
  final TouristPlace? nearestPlace;
}

class ArExplorationService {
  Future<ArExplorationResult> startSession({
    required List<TouristPlace> visiblePlaces,
  }) async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return ArExplorationResult(
        supported: false,
        message: 'AR exploration is mobile-only. Opening map exploration instead.',
        nearestPlace: visiblePlaces.isEmpty ? null : visiblePlaces.first,
      );
    }

    return ArExplorationResult(
      supported: true,
      message:
          'AR session bridge is ready. Native ARCore/ARKit package integration can attach here.',
      nearestPlace: visiblePlaces.isEmpty ? null : visiblePlaces.first,
    );
  }
}
