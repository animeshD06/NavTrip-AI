import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/itinerary.dart';
import '../providers/trip_planner_controller.dart';
import 'tourist_map_screen.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itinerary = context.watch<TripPlannerController>().itinerary;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Itinerary'),
      ),
      body: itinerary == null
          ? const _EmptyItinerary()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itinerary.destination,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _SummaryChip(
                              icon: Icons.calendar_month,
                              label: '${itinerary.days.length} days',
                            ),
                            _SummaryChip(
                              icon: Icons.place,
                              label: '${itinerary.totalPlaces} places',
                            ),
                            _SummaryChip(
                              icon: Icons.auto_awesome,
                              label: itinerary.generatedBy,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (final day in itinerary.days)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day ${day.dayNumber}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: day.places.isEmpty
                                  ? null
                                  : () => _openRoutePreview(context, day),
                              icon: const Icon(Icons.route),
                              label: const Text('View route'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final place in day.places) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  child: Text('${place.sequenceOrder}'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${place.category} - ${place.estimatedVisitMinutes} min',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (place.sequenceOrder > 1)
                                        Text(
                                          '${place.travelDistanceKm.toStringAsFixed(1)} km from previous - about ${place.estimatedTravelMinutes} min',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      if (place.sequenceOrder > 1)
                                        const SizedBox(height: 2),
                                      Text(
                                        '${place.openingTime}-${place.closingTime}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (place != day.places.last)
                              const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: SizedBox(
                                  height: 24,
                                  child: VerticalDivider(),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _openRoutePreview(BuildContext context, ItineraryDay day) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TouristMapScreen(routeDay: day),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
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
      side: BorderSide.none,
      backgroundColor: theme.colorScheme.surface,
    );
  }
}

class _EmptyItinerary extends StatelessWidget {
  const _EmptyItinerary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No itinerary generated yet.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create one from the planner to see a day-wise route here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to planner'),
            ),
          ],
        ),
      ),
    );
  }
}
