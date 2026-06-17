import 'package:flutter_tts/flutter_tts.dart';

import '../models/tourist_place.dart';

enum NarrationMode {
  short,
  medium,
  detailed,
}

class VoiceNarrationService {
  VoiceNarrationService() {
    _configure();
  }

  final FlutterTts _tts = FlutterTts();
  String _language = 'en-IN';

  Future<void> speakPlace(
    TouristPlace place, {
    NarrationMode mode = NarrationMode.medium,
    String language = 'en-IN',
    String? cachedNarration,
  }) async {
    if (_language != language) {
      _language = language;
      await _tts.setLanguage(language);
    }

    final narration = cachedNarration ?? _buildNarration(place, mode);

    await _tts.stop();
    await _tts.speak(narration);
  }

  String _buildNarration(TouristPlace place, NarrationMode mode) {
    final timing = place.openingTime.isEmpty || place.closingTime.isEmpty
        ? ''
        : ' Open from ${place.openingTime} to ${place.closingTime}.';

    switch (mode) {
      case NarrationMode.short:
        return '${place.name}. ${place.category} stop in ${place.city}. Rating ${place.rating.toStringAsFixed(1)} out of 5.';
      case NarrationMode.detailed:
        return '${place.name}. ${place.description} This place is culturally useful for ${place.category} travelers. Rating ${place.rating.toStringAsFixed(1)} out of 5.$timing';
      case NarrationMode.medium:
        return '${place.name}. ${place.description} Rating ${place.rating.toStringAsFixed(1)} out of 5.$timing';
    }
  }

  Future<void> stop() => _tts.stop();

  Future<void> dispose() => _tts.stop();

  Future<void> _configure() async {
    await _tts.setLanguage(_language);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1);
  }
}
