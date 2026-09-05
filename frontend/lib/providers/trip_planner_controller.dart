import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/itinerary.dart';
import '../models/tourist_place.dart';
import '../services/api_client.dart';
import '../services/offline_saved_trips_service.dart';

class TripPlannerController extends ChangeNotifier {
  TripPlannerController(
    this._apiClient, {
    OfflineSavedTripsService? offlineSavedTripsService,
  }) : _offlineSavedTripsService =
            offlineSavedTripsService ?? OfflineSavedTripsService();

  final ApiClient _apiClient;
  final OfflineSavedTripsService _offlineSavedTripsService;

  String destination = 'Jaipur';
  String category = 'historical';
  String searchQuery = '';
  int days = 2;
  String budgetTier = 'moderate';
  String travelStyle = 'balanced';
  int groupSize = 2;
  List<String> interests = const ['historical', 'culture', 'scenic'];
  DateTime? startDate;

  bool isLoading = false;
  bool isCheckingBackend = false;
  bool backendConnected = false;
  bool offlineTripLoaded = false;
  String backendStatus = 'Checking backend...';
  String? errorMessage;
  String? infoMessage;
  List<TouristPlace> places = [];
  Itinerary? itinerary;
  List<CachedTrip> cachedTrips = [];

  Future<void> initialize() async {
    await loadCachedTrips();
    await restoreLatestCachedTrip();

    // Run backend check in background — UI is already showing cached data.
    unawaited(_checkBackendAndLoad());
  }

  Future<void> _checkBackendAndLoad() async {
    await checkBackend();
    if (backendConnected) {
      await loadPlaces();
    }
  }

  Future<void> loadCachedTrips() async {
    try {
      cachedTrips = await _offlineSavedTripsService.loadTrips();
    } catch (_) {
      cachedTrips = [];
    }
    notifyListeners();
  }

  Future<void> restoreLatestCachedTrip() async {
    final cachedTrip = cachedTrips.isEmpty
        ? await _offlineSavedTripsService.loadLatestTrip()
        : cachedTrips.first;
    if (cachedTrip == null) {
      return;
    }

    destination = cachedTrip.destination.isEmpty ? destination : cachedTrip.destination;
    category = cachedTrip.category.isEmpty ? category : cachedTrip.category;
    days = cachedTrip.days <= 0 ? days : cachedTrip.days;
    itinerary = cachedTrip.itinerary;
    offlineTripLoaded = true;
    infoMessage = 'Loaded your latest saved trip for offline viewing.';
    notifyListeners();
  }

  Future<void> checkBackend() async {
    isCheckingBackend = true;
    backendStatus = 'Checking backend...';
    errorMessage = null;
    infoMessage = null;
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
      itinerary = await _apiClient.createTrip(
        destination: destination,
        days: days,
        category: category,
      );
      await _offlineSavedTripsService.saveTrip(
        destination: destination,
        category: category,
        days: days,
        itinerary: itinerary!,
      );
      cachedTrips = await _offlineSavedTripsService.loadTrips();
      offlineTripLoaded = false;
      infoMessage = 'Trip saved locally for offline access.';
      places = await _apiClient.fetchPlaces(
        city: destination,
        category: category,
        search: searchQuery,
      );
    });
  }

  Future<void> setTripPlan({
    required String newDestination,
    required int newDays,
    required String newCategory,
    String? newBudgetTier,
    String? newTravelStyle,
    int? newGroupSize,
    List<String>? newInterests,
    DateTime? newStartDate,
    bool autoGenerate = true,
  }) async {
    destination = newDestination.trim().isEmpty ? 'Jaipur' : newDestination.trim();
    days = newDays <= 0 ? 2 : newDays;
    category = newCategory.isEmpty ? 'historical' : newCategory;
    if (newBudgetTier != null) budgetTier = newBudgetTier;
    if (newTravelStyle != null) travelStyle = newTravelStyle;
    if (newGroupSize != null) groupSize = newGroupSize;
    if (newInterests != null) interests = List.unmodifiable(newInterests);
    if (newStartDate != null) startDate = newStartDate;

    notifyListeners();

    if (autoGenerate) {
      await generateItinerary();
    } else {
      await loadPlaces();
    }
  }

  Future<void> selectPresetDestination(
    String newDestination, {
    String? newCategory,
    int? newDays,
  }) async {
    destination = newDestination.trim().isEmpty ? destination : newDestination.trim();
    if (newCategory != null && newCategory.isNotEmpty) {
      category = newCategory;
    }
    if (newDays != null && newDays > 0) {
      days = newDays;
    }
    notifyListeners();
    await generateItinerary();
  }

  Future<void> applyCachedTrip(CachedTrip cachedTrip) async {
    destination = cachedTrip.destination;
    category = cachedTrip.category;
    days = cachedTrip.days;
    itinerary = cachedTrip.itinerary;
    offlineTripLoaded = true;
    infoMessage = 'Loaded saved itinerary for $destination.';
    notifyListeners();
    if (backendConnected) {
      await loadPlaces();
    }
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

  void updateBudgetTier(String value) {
    budgetTier = value;
    notifyListeners();
  }

  void updateTravelStyle(String value) {
    travelStyle = value;
    notifyListeners();
  }

  void updateGroupSize(int value) {
    groupSize = value;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    infoMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      errorMessage = _friendlyError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('connection') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('network')) {
      return 'Network connection failed. Check the backend and try again.';
    }

    if (message.contains('400')) {
      return 'Check your trip details and try again.';
    }

    return 'Something went wrong. Try again in a moment.';
  }
}
