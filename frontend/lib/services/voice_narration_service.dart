import 'package:flutter_tts/flutter_tts.dart';

import '../models/tourist_place.dart';

class VoiceNarrationService {
  VoiceNarrationService() {
    _configure();
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speakPlace(TouristPlace place) async {
    final timing = place.openingTime.isEmpty || place.closingTime.isEmpty
        ? ''
        : ' Open from ${place.openingTime} to ${place.closingTime}.';

    await _tts.stop();
    await _tts.speak(
      '${place.name}. ${place.description} Rating ${place.rating.toStringAsFixed(1)} out of 5.$timing',
    );
  }

  Future<void> stop() => _tts.stop();

  Future<void> dispose() => _tts.stop();

  Future<void> _configure() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1);
  }
}
