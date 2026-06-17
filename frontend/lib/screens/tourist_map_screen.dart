import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/itinerary.dart';
import '../models/tourist_place.dart';
import '../providers/trip_planner_controller.dart';
import '../services/voice_narration_service.dart';

class TouristMapScreen extends StatefulWidget {
  const TouristMapScreen({
    this.initialPlace,
    this.routeDay,
    super.key,
  });

  final TouristPlace? initialPlace;
  final ItineraryDay? routeDay;

  @override
  State<TouristMapScreen> createState() => _TouristMapScreenState();
}

class _TouristMapScreenState extends State<TouristMapScreen> {
  final _mapController = MapController();
  final _voiceNarrationService = VoiceNarrationService();

  LatLng? _currentLocation;
  String? _locationError;
  TouristPlace? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _selectedPlace = widget.initialPlace;
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _voiceNarrationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TripPlannerController>();
    final places = controller.places;
    final routePlaces = widget.routeDay?.places ?? const <ItineraryPlace>[];
    final routePoints = routePlaces
        .map((place) => LatLng(place.latitude, place.longitude))
        .toList();
    final selectedPoint = _selectedPlace == null
        ? null
        : LatLng(_selectedPlace!.latitude, _selectedPlace!.longitude);
    final center = selectedPoint ??
        _currentLocation ??
        (routePoints.isEmpty ? null : routePoints.first) ??
        (places.isEmpty
            ? const LatLng(26.9124, 75.7873)
            : LatLng(places.first.latitude, places.first.longitude));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.routeDay == null
              ? 'Tourist Map'
              : 'Day ${widget.routeDay!.dayNumber} route',
        ),
        actions: [
          IconButton(
            tooltip: 'Stop narration',
            onPressed: _voiceNarrationService.stop,
            icon: const Icon(Icons.volume_off),
          ),
          IconButton(
            tooltip: 'Use current location',
            onPressed: _loadCurrentLocation,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: selectedPoint == null ? 13 : 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.navtrip.ai',
              ),
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.navigation,
                        color: Color(0xff2563eb),
                        size: 36,
                      ),
                    ),
                  for (final place in places)
                    Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: 52,
                      height: 52,
                      child: IconButton.filled(
                        tooltip: place.name,
                        style: IconButton.styleFrom(
                          backgroundColor: place.id == _selectedPlace?.id
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: place.id == _selectedPlace?.id
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                        ),
                        onPressed: () => _selectPlace(place),
                        icon: const Icon(Icons.place),
                      ),
                    ),
                  for (final place in routePlaces)
                    Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: 42,
                      height: 42,
                      child: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                        child: Text('${place.sequenceOrder}'),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (places.isNotEmpty)
            Positioned(
              left: 12,
              right: 12,
              bottom: _locationError == null ? 12 : 96,
              child: _MapPlaceStrip(
                places: places,
                selectedPlace: _selectedPlace,
                onSelected: _selectPlace,
                onDetails: (place) => _showPlaceDetails(context, place),
              ),
            ),
          if (_locationError != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _locationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _selectPlace(TouristPlace place) {
    setState(() {
      _selectedPlace = place;
    });

    _mapController.move(LatLng(place.latitude, place.longitude), 15);
    _voiceNarrationService.speakPlace(place);
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _locationError = null;
    });

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = 'Location services are disabled.';
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError =
            'Location permission is required to show your position.';
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    if (!mounted) {
      return;
    }

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _showPlaceDetails(BuildContext context, TouristPlace place) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${place.category} - Rating ${place.rating.toStringAsFixed(1)}',
              ),
              const SizedBox(height: 12),
              Text(place.description),
              const SizedBox(height: 12),
              Text('Open ${place.openingTime} to ${place.closingTime}'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => _voiceNarrationService.speakPlace(place),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Narrate'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _voiceNarrationService.stop,
                    icon: const Icon(Icons.volume_off),
                    label: const Text('Stop'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapPlaceStrip extends StatelessWidget {
  const _MapPlaceStrip({
    required this.places,
    required this.selectedPlace,
    required this.onSelected,
    required this.onDetails,
  });

  final List<TouristPlace> places;
  final TouristPlace? selectedPlace;
  final ValueChanged<TouristPlace> onSelected;
  final ValueChanged<TouristPlace> onDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 4,
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(10),
          itemCount: places.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final place = places[index];
            final isSelected = place.id == selectedPlace?.id;

            return InkWell(
              onTap: () => onSelected(place),
              onLongPress: () => onDetails(place),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.star,
                          size: 15,
                          color: theme.colorScheme.primary,
                        ),
                        Text(place.rating.toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.state.isEmpty
                          ? '${place.category} - ${place.city}'
                          : '${place.category} - ${place.city}, ${place.state}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => onDetails(place),
                        child: const Text('Details'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
