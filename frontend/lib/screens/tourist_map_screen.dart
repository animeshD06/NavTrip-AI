import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/itinerary.dart';
import '../models/tourist_place.dart';
import '../providers/trip_planner_controller.dart';
import '../services/ar_exploration_service.dart';
import '../services/geofencing_voice_tour_service.dart';
import '../services/api_client.dart';
import '../services/voice_narration_service.dart';
import '../theme/navtrip_theme.dart';
import '../widgets/home/trip_location_and_details_sheet.dart';

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
  late final GeofencingVoiceTourService _geofencingVoiceTourService;
  final _arExplorationService = ArExplorationService();

  LatLng? _currentLocation;
  String? _locationError;
  TouristPlace? _selectedPlace;
  VoiceTourSettings _voiceTourSettings = const VoiceTourSettings();

  @override
  void initState() {
    super.initState();
    _geofencingVoiceTourService = GeofencingVoiceTourService(_voiceNarrationService);
    _selectedPlace = widget.initialPlace;
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _geofencingVoiceTourService.dispose();
    _voiceNarrationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TripPlannerController>();
    final places = controller.places;
    _geofencingVoiceTourService.updatePlaces(places);

    final routePlaces = widget.routeDay?.places ?? const <ItineraryPlace>[];
    final routePoints = routePlaces.map((place) => LatLng(place.latitude, place.longitude)).toList();
    final selectedPoint = _selectedPlace == null ? null : LatLng(_selectedPlace!.latitude, _selectedPlace!.longitude);
    final center = selectedPoint ?? _currentLocation ?? (routePoints.isNotEmpty ? routePoints.first : null) ?? (places.isNotEmpty ? LatLng(places.first.latitude, places.first.longitude) : const LatLng(26.9124, 75.7873));

    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 980;

    return Scaffold(
      body: PaperTexture(
        child: SafeArea(
          child: Column(
            children: [
              _HeaderBar(
                title: widget.routeDay == null ? 'Tourist Map' : 'Day ${widget.routeDay!.dayNumber} route',
                onAr: () => _startArExploration(context, places),
                onStop: _voiceNarrationService.stop,
                onLocation: _loadCurrentLocation,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(
                            child: _MapCanvas(
                              mapController: _mapController,
                              center: center,
                              places: places,
                              routePoints: routePoints,
                              currentLocation: _currentLocation,
                              selectedPlace: _selectedPlace,
                              isLoading: controller.isLoading,
                              statusMessage: controller.errorMessage ??
                                  controller.infoMessage,
                              onSelectPlace: _selectPlace,
                            ),
                          ),
                          SizedBox(
                            width: 420,
                            child: _SidebarPanel(
                              places: places,
                              routePlaces: routePlaces,
                              selectedPlace: _selectedPlace,
                              voiceSettings: _voiceTourSettings,
                              onVoiceSettingsChanged: _updateVoiceTourSettings,
                              onPlaceDetails: (place) => _showPlaceDetails(context, place),
                              onOpenRoute: routePlaces.isEmpty ? null : () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _MapCanvas(
                              mapController: _mapController,
                              center: center,
                              places: places,
                              routePoints: routePoints,
                              currentLocation: _currentLocation,
                              selectedPlace: _selectedPlace,
                              isLoading: controller.isLoading,
                              statusMessage: controller.errorMessage ??
                                  controller.infoMessage,
                              onSelectPlace: _selectPlace,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _SidebarPanel(
                              places: places,
                              routePlaces: routePlaces,
                              selectedPlace: _selectedPlace,
                              voiceSettings: _voiceTourSettings,
                              onVoiceSettingsChanged: _updateVoiceTourSettings,
                              onPlaceDetails: (place) => _showPlaceDetails(context, place),
                              onOpenRoute: routePlaces.isEmpty ? null : () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ],
                      ),
              ),
              if (_locationError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _locationError!,
                      style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectPlace(TouristPlace place) async {
    setState(() {
      _selectedPlace = place;
    });

    _mapController.move(LatLng(place.latitude, place.longitude), 15);

    String? cachedNarration;
    try {
      cachedNarration = (await context.read<ApiClient>().fetchNarration(
            placeId: place.id,
            mode: _voiceTourSettings.mode.name,
            language: _voiceTourSettings.language,
          ))['content'] as String?;
    } catch (_) {
      cachedNarration = null;
    }

    await _voiceNarrationService.speakPlace(
      place,
      mode: _voiceTourSettings.mode,
      language: _voiceTourSettings.language,
      cachedNarration: cachedNarration,
    );
  }

  Future<void> _updateVoiceTourSettings(VoiceTourSettings settings) async {
    setState(() {
      _voiceTourSettings = settings;
    });
    await _geofencingVoiceTourService.updateSettings(settings);
  }

  Future<void> _startArExploration(BuildContext context, List<TouristPlace> places) async {
    final result = await _arExplorationService.startSession(visiblePlaces: places);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    if (!result.supported && result.nearestPlace != null) {
      await _selectPlace(result.nearestPlace!);
    }
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _locationError = null);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationError = 'Location services are disabled.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _locationError = 'Location permission is required to show your position.');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

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
              Text(place.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('${place.category} • Rating ${place.rating.toStringAsFixed(1)}'),
              const SizedBox(height: 12),
              Text(place.description),
              const SizedBox(height: 12),
              Text('Open ${place.openingTime} to ${place.closingTime}'),
              const SizedBox(height: 16),              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => _voiceNarrationService.speakPlace(
                      place,
                      mode: _voiceTourSettings.mode,
                      language: _voiceTourSettings.language,
                    ),
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

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.title,
    required this.onAr,
    required this.onStop,
    required this.onLocation,
    required this.onBack,
  });

  final String title;
  final VoidCallback onAr;
  final VoidCallback onStop;
  final VoidCallback onLocation;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TripPlannerController>();
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 600 ? 20 : 64,
          vertical: 14),
      decoration: const BoxDecoration(
        color: NavTripPalette.surface,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: NavTripPalette.terracottaDeep,
                    fontSize:
                        MediaQuery.sizeOf(context).width < 600 ? 30 : 40,
                  ),
            ),
          ),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => TripLocationAndDetailsSheet.show(context),
                icon: const Icon(Icons.edit_location_alt_outlined, size: 16),
                label: Text(controller.destination),
              ),
              if (MediaQuery.sizeOf(context).width >= 720) ...[
                OutlinedButton.icon(
                    onPressed: onAr,
                    icon: const Icon(Icons.view_in_ar),
                    label: const Text('AR')),
                OutlinedButton.icon(
                    onPressed: onStop,
                    icon: const Icon(Icons.volume_off),
                    label: const Text('Stop')),
                OutlinedButton.icon(
                    onPressed: onLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Locate')),
              ] else ...[
                IconButton(onPressed: onAr, icon: const Icon(Icons.view_in_ar)),
                IconButton(
                    onPressed: onLocation, icon: const Icon(Icons.my_location)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.mapController,
    required this.center,
    required this.places,
    required this.routePoints,
    required this.currentLocation,
    required this.selectedPlace,
    required this.isLoading,
    required this.statusMessage,
    required this.onSelectPlace,
  });

  final MapController mapController;
  final LatLng center;
  final List<TouristPlace> places;
  final List<LatLng> routePoints;
  final LatLng? currentLocation;
  final TouristPlace? selectedPlace;
  final bool isLoading;
  final String? statusMessage;
  final ValueChanged<TouristPlace> onSelectPlace;

  @override
  Widget build(BuildContext context) {
    final placeClusters = _clusterPlaces(places, selectedPlace);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: NavTripStyles.paperCard(radius: 14),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: selectedPlace == null ? 13 : 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.navtrip.ai',
                ),
                if (routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: routePoints, color: NavTripPalette.terracotta, strokeWidth: 5),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (currentLocation != null)
                      Marker(
                        point: currentLocation!,
                        width: 44,
                        height: 44,
                        child: const Icon(Icons.navigation, color: Color(0xff2563eb), size: 34),
                      ),
                    for (final cluster in placeClusters)
                      Marker(
                        point: cluster.center,
                        width: cluster.isCluster ? 62 : 52,
                        height: cluster.isCluster ? 62 : 52,
                        child: cluster.isCluster
                            ? _ClusterMarker(
                                count: cluster.places.length,
                                onTap: () => _zoomToCluster(cluster),
                              )
                            : _PlaceMarker(
                                place: cluster.places.first,
                                selected: cluster.places.first.id ==
                                    selectedPlace?.id,
                                onTap: () => onSelectPlace(cluster.places.first),
                              ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 34,
          top: 34,
          child: Column(
            children: [
              _MapButton(icon: Icons.add, onPressed: () => _changeZoom(1)),
              const SizedBox(height: 8),
              _MapButton(icon: Icons.remove, onPressed: () => _changeZoom(-1)),
            ],
          ),
        ),
        if (places.isNotEmpty)
          Positioned(
            left: 34,
            right: 34,
            bottom: 34,
            child: _DestinationStrip(
              places: places,
              selectedPlace: selectedPlace,
              onSelected: onSelectPlace,
              onDetails: (place) => _showPlaceDetailsFromContext(context, place),
            ),
          ),
        if (isLoading || statusMessage != null || places.isEmpty)
          Positioned(
            left: 34,
            top: 34,
            child: _MapStatusPill(
              isLoading: isLoading,
              message: isLoading
                  ? 'Loading map data...'
                  : statusMessage ??
                      'No places loaded yet. Check filters or reconnect.',
            ),
          ),
      ],
    );
  }

  void _showPlaceDetailsFromContext(BuildContext context, TouristPlace place) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Text(place.name),
      ),
    );
  }

  List<_PlaceCluster> _clusterPlaces(
    List<TouristPlace> places,
    TouristPlace? selectedPlace,
  ) {
    const gridSize = 0.018;
    final selectedId = selectedPlace?.id;
    final groupedPlaces = <String, List<TouristPlace>>{};
    final clusters = <_PlaceCluster>[];

    for (final place in places) {
      if (place.id == selectedId) {
        clusters.add(_PlaceCluster.single(place));
        continue;
      }

      final latBucket = (place.latitude / gridSize).round();
      final lngBucket = (place.longitude / gridSize).round();
      final key = '$latBucket:$lngBucket';
      groupedPlaces.putIfAbsent(key, () => []).add(place);
    }

    for (final group in groupedPlaces.values) {
      clusters.add(_PlaceCluster(group));
    }

    return clusters;
  }

  void _zoomToCluster(_PlaceCluster cluster) {
    final camera = mapController.camera;
    mapController.move(cluster.center, (camera.zoom + 2).clamp(3, 18));
  }

  void _changeZoom(double delta) {
    final camera = mapController.camera;
    mapController.move(camera.center, (camera.zoom + delta).clamp(3, 18));
  }
}

class _MapStatusPill extends StatelessWidget {
  const _MapStatusPill({
    required this.isLoading,
    required this.message,
  });

  final bool isLoading;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.12),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              Icons.info_outline,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceCluster {
  _PlaceCluster(this.places)
      : center = LatLng(
          places.map((place) => place.latitude).reduce((a, b) => a + b) /
              places.length,
          places.map((place) => place.longitude).reduce((a, b) => a + b) /
              places.length,
        );

  _PlaceCluster.single(TouristPlace place)
      : places = [place],
        center = LatLng(place.latitude, place.longitude);

  final List<TouristPlace> places;
  final LatLng center;

  bool get isCluster => places.length > 1;
}

class _ClusterMarker extends StatelessWidget {
  const _ClusterMarker({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: Container(
          decoration: BoxDecoration(
            color: NavTripPalette.terracottaDeep,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.24),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  const _PlaceMarker({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final TouristPlace place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: place.name,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor:
            selected ? NavTripPalette.terracotta : NavTripPalette.terracottaSoft,
        foregroundColor:
            selected ? Colors.white : NavTripPalette.terracottaDeep,
      ),
      icon: const Icon(Icons.place),
    );
  }
}

class _SidebarPanel extends StatelessWidget {
  const _SidebarPanel({
    required this.places,
    required this.routePlaces,
    required this.selectedPlace,
    required this.voiceSettings,
    required this.onVoiceSettingsChanged,
    required this.onPlaceDetails,
    required this.onOpenRoute,
  });

  final List<TouristPlace> places;
  final List<ItineraryPlace> routePlaces;
  final TouristPlace? selectedPlace;
  final VoiceTourSettings voiceSettings;
  final ValueChanged<VoiceTourSettings> onVoiceSettingsChanged;
  final ValueChanged<TouristPlace> onPlaceDetails;
  final VoidCallback? onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: NavTripStyles.paperCard(radius: 14),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Voice Tour', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: NavTripPalette.terracottaDeep)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('Auto guide'),
                      selected: voiceSettings.enabled,
                      onSelected: (value) => onVoiceSettingsChanged(voiceSettings.copyWith(enabled: value)),
                    ),
                    DropdownButton<int>(
                      value: voiceSettings.radiusMeters,
                      underline: const SizedBox.shrink(),
                      items: const [50, 100, 200].map((value) => DropdownMenuItem(value: value, child: Text('${value}m'))).toList(),
                      onChanged: (value) {
                        if (value != null) onVoiceSettingsChanged(voiceSettings.copyWith(radiusMeters: value));
                      },
                    ),
                    DropdownButton<NarrationMode>(
                      value: voiceSettings.mode,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: NarrationMode.short, child: Text('Short')),
                        DropdownMenuItem(value: NarrationMode.medium, child: Text('Medium')),
                        DropdownMenuItem(value: NarrationMode.detailed, child: Text('Detailed')),
                      ],
                      onChanged: (value) {
                        if (value != null) onVoiceSettingsChanged(voiceSettings.copyWith(mode: value));
                      },
                    ),
                  ],
                ),
                if (selectedPlace != null) ...[
                  const SizedBox(height: 14),
                  Text(selectedPlace!.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(selectedPlace!.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NavTripPalette.mutedInk)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(onPressed: () => onPlaceDetails(selectedPlace!), child: const Text('Details')),
                      OutlinedButton(onPressed: () {}, child: const Text('Stop')),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: NavTripStyles.paperCard(radius: 14),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Route Timeline', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: NavTripPalette.terracottaDeep)),
                      if (onOpenRoute != null)
                        TextButton(onPressed: onOpenRoute, child: const Text('Open trip')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: routePlaces.isNotEmpty
                        ? ListView.separated(
                            itemBuilder: (context, index) {
                              final place = routePlaces[index];
                              return _RouteTimelineItem(place: place);
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: routePlaces.length,
                          )
                        : (places.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  final place = places[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(place.name),
                                    subtitle: Text(place.category),
                                    trailing: Text(place.rating.toStringAsFixed(1)),
                                    onTap: () => onPlaceDetails(place),
                                  );
                                },
                                separatorBuilder: (_, __) => const Divider(),
                                itemCount: places.length,
                              )
                            : const Center(child: Text('Load a trip to see route items here.'))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteTimelineItem extends StatelessWidget {
  const _RouteTimelineItem({required this.place});

  final ItineraryPlace place;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: NavTripPalette.terracotta, width: 2),
          ),
          child: Center(child: Text('${place.sequenceOrder}', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: NavTripPalette.terracottaDeep))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('${place.category} • ${place.estimatedVisitMinutes} min', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NavTripPalette.mutedInk)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DestinationStrip extends StatelessWidget {
  const _DestinationStrip({
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
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffdec0b7)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(10),
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final place = places[index];
          final selected = place.id == selectedPlace?.id;
          return InkWell(
            onTap: () => onSelected(place),
            onLongPress: () => onDetails(place),
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: selected ? NavTripPalette.terracotta : const Color(0xffdec0b7)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall)),
                      const SizedBox(width: 6),
                      Icon(Icons.star, size: 16, color: NavTripPalette.terracotta),
                      Text(place.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.state.isEmpty ? '${place.category} - ${place.city}' : '${place.category} - ${place.city}, ${place.state}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NavTripPalette.mutedInk),
                  ),
                  const Spacer(),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => onDetails(place), child: const Text('Details'))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: NavTripPalette.terracotta),
      ),
    );
  }
}




