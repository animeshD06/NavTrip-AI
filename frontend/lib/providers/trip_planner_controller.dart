import 'package:flutter/foundation.dart';

import '../models/itinerary.dart';
import '../models/tourist_place.dart';
import '../services/api_client.dart';

class TripPlannerController extends ChangeNotifier {
  TripPlannerController(this._apiClient);

  final ApiClient _apiClient;

  String destination = 'Jaipur';
  String category = 'historical';
  String searchQuery = '';
  int days = 2;

  bool isLoading = false;
  bool isCheckingBackend = false;
  bool backendConnected = false;
  String backendStatus = 'Checking backend...';
  String? errorMessage;
  List<TouristPlace> places = [];
  Itinerary? itinerary;

  Future<void> initialize() async {
    await checkBackend();

    if (backendConnected) {
      await loadPlaces();
    }
  }

  Future<void> checkBackend() async {
    isCheckingBackend = true;
    backendStatus = 'Checking backend...';
    errorMessage = null;
    notifyListeners();

    try {
      final health = await _apiClient.fetchHealth();
      backendConnected = health['status'] == 'ok';
      backendStatus = backendConnected
          ? 'Backend connected'
          : 'Backend returned an unexpected status';
    } catch (error) {
      backendConnected = false;
      backendStatus = 'Backend unavailable';
      errorMessage =
          'Could not reach backend at ${ApiClient.baseUrlLabel}. Start the backend and refresh.';
    } finally {
      isCheckingBackend = false;
      notifyListeners();
    }
  }

  Future<void> loadPlaces() async {
    await _run(() async {
      places = await _apiClient.fetchPlaces(
        city: destination,
        category: category,
        search: searchQuery,
      );
    });
  }

  Future<void> generateItinerary() async {
    await _run(() async {
      itinerary = await _apiClient.generateItinerary(
        destination: destination,
        days: days,
        category: category,
      );
      places = await _apiClient.fetchPlaces(
        city: destination,
        category: category,
        search: searchQuery,
      );
    });
  }

  void updateDestination(String value) {
    destination = value.trim().isEmpty ? 'Jaipur' : value.trim();
    notifyListeners();
  }

  void updateCategory(String value) {
    category = value;
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    searchQuery = value.trim();
    notifyListeners();
  }

  void updateDays(double value) {
    days = value.round();
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
