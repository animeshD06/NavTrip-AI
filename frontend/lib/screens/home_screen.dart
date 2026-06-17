import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tourist_place.dart';
import '../providers/trip_planner_controller.dart';
import '../widgets/category_filter.dart';
import 'itinerary_screen.dart';
import 'tourist_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.loadPlacesOnStart = true,
    super.key,
  });

  final bool loadPlacesOnStart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _destinationController = TextEditingController(text: 'Jaipur');
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.loadPlacesOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TripPlannerController>().initialize();
      });
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TripPlannerController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NavTrip AI'),
        actions: [
          IconButton(
            tooltip: 'Refresh places',
            onPressed: controller.isLoading ? null : controller.loadPlaces,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 840;
            final planner = _PlannerPanel(
              destinationController: _destinationController,
              searchController: _searchController,
              controller: controller,
              onGenerate: () => _generateItinerary(context, controller),
            );
            final results = _PlacesPanel(controller: controller);

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 380,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [planner],
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [results],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                planner,
                const SizedBox(height: 20),
                results,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _generateItinerary(
    BuildContext context,
    TripPlannerController controller,
  ) async {
    controller.updateDestination(_destinationController.text);
    await controller.generateItinerary();

    if (!context.mounted || controller.itinerary == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ItineraryScreen(),
      ),
    );
  }
}

class _PlannerPanel extends StatelessWidget {
  const _PlannerPanel({
    required this.destinationController,
    required this.searchController,
    required this.controller,
    required this.onGenerate,
  });

  final TextEditingController destinationController;
  final TextEditingController searchController;
  final TripPlannerController controller;
  final Future<void> Function() onGenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Plan a smarter city trip',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose a destination, tune the vibe, and generate a day-wise route.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: destinationController,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            labelText: 'Destination',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
          onChanged: controller.updateDestination,
          onSubmitted: (value) {
            controller.updateDestination(value);
            controller.loadPlaces();
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Search places',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      searchController.clear();
                      controller.updateSearchQuery('');
                      controller.loadPlaces();
                    },
                    icon: const Icon(Icons.close),
                  ),
            border: const OutlineInputBorder(),
          ),
          onChanged: controller.updateSearchQuery,
          onSubmitted: (_) => controller.loadPlaces(),
        ),
        const SizedBox(height: 12),
        _BackendStatus(controller: controller),
        const SizedBox(height: 20),
        CategoryFilter(
          selectedCategory: controller.category,
          onChanged: (value) {
            controller.updateCategory(value);
            controller.loadPlaces();
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Trip length',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              '${controller.days} days',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          min: 1,
          max: 7,
          divisions: 6,
          value: controller.days.toDouble(),
          label: '${controller.days}',
          onChanged: controller.updateDays,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: controller.isLoading ? null : onGenerate,
          icon: controller.isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: const Text('Generate itinerary'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TouristMapScreen(),
              ),
            );
          },
          icon: const Icon(Icons.map),
          label: const Text('Open tourist map'),
        ),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 16),
          _ErrorNotice(message: controller.errorMessage!),
        ],
      ],
    );
  }
}

class _BackendStatus extends StatelessWidget {
  const _BackendStatus({required this.controller});

  final TripPlannerController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = controller.backendConnected;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: isConnected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.backendStatus,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed:
                  controller.isCheckingBackend ? null : controller.initialize,
              child: const Text('Reconnect'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacesPanel extends StatelessWidget {
  const _PlacesPanel({required this.controller});

  final TripPlannerController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${controller.places.length} places found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (controller.isLoading)
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!controller.isLoading && controller.places.isEmpty)
          const _EmptyPlaces()
        else
          for (final place in controller.places) ...[
            _PlaceCard(place: place),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final TouristPlace place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.place, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RatingBadge(rating: place.rating),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.category,
                  label: place.category,
                ),
                _InfoChip(
                  icon: Icons.schedule,
                  label: '${place.openingTime}-${place.closingTime}',
                ),
                _InfoChip(
                  icon: Icons.location_city,
                  label: place.state.isEmpty
                      ? place.city
                      : '${place.city}, ${place.state}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TouristMapScreen(initialPlace: place),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('View on map'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 16,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: theme.colorScheme.outlineVariant),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPlaces extends StatelessWidget {
  const _EmptyPlaces();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.travel_explore,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No places loaded yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Reconnect or refresh after the backend is running.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
