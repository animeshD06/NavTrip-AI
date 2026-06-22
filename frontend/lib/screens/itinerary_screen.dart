import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/itinerary.dart';
import '../providers/trip_planner_controller.dart';
import '../theme/navtrip_theme.dart';
import 'tourist_map_screen.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TripPlannerController>();
    final itinerary = controller.itinerary;

    return Scaffold(
      body: PaperTexture(
        child: SafeArea(
          child: itinerary == null ? _emptyState(context, controller) : _detailsLayout(context, itinerary),
        ),
      ),
    );
  }

  Widget _detailsLayout(BuildContext context, Itinerary itinerary) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 980;
    final currentDay = itinerary.days[_selectedDayIndex.clamp(0, itinerary.days.length - 1).toInt()];

    return Column(
      children: [
        _HeaderBar(destination: itinerary.destination),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(width < 600 ? 20 : 64, 0, width < 600 ? 20 : 64, 20),
            children: [
              _HeroBanner(itinerary: itinerary),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final selected = index == _selectedDayIndex;
                    return ChoiceChip(
                      label: Text('Day ${itinerary.days[index].dayNumber}'),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedDayIndex = index),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: itinerary.days.length,
                ),
              ),
              const SizedBox(height: 16),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _TimelineCard(day: currentDay, onViewRoute: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TouristMapScreen(routeDay: currentDay))))),
                    const SizedBox(width: 24),
                    SizedBox(width: 320, child: _SidebarWidgets()),
                  ],
                )
              else ...[
                _SidebarWidgets(),
                const SizedBox(height: 16),
                _TimelineCard(day: currentDay, onViewRoute: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TouristMapScreen(routeDay: currentDay)))),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context, TripPlannerController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: NavTripStyles.paperCard(radius: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.route, size: 54, color: NavTripPalette.terracotta),
                const SizedBox(height: 12),
                Text('No itinerary generated yet.', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Create one from the dashboard to see the journal-style timeline here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: NavTripPalette.mutedInk),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await controller.generateItinerary();
                        if (mounted) setState(() {});
                      },
                      child: const Text('Generate Itinerary'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
                      child: const Text('Back to dashboard'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.destination});

  final String destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width < 600 ? 20 : 64, vertical: 18),
      decoration: const BoxDecoration(
        color: NavTripPalette.surface,
        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 8, offset: Offset(0, 1))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('NavTrip-AI', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: NavTripPalette.terracottaDeep, fontSize: MediaQuery.sizeOf(context).width < 600 ? 34 : 44)),
          Text(destination, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: NavTripPalette.mutedInk)),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.itinerary});

  final Itinerary itinerary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NavTripStyles.paperCard(radius: 12),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itinerary.destination, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: NavTripPalette.terracotta, fontSize: 54)),
                const SizedBox(height: 10),
                Text(
                  'A ${itinerary.days.length}-day odyssey through curated stops, travel notes, and route detail.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: NavTripPalette.mutedInk),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SummaryChip(icon: Icons.calendar_month, label: '${itinerary.days.length} days'),
                    _SummaryChip(icon: Icons.place, label: '${itinerary.totalPlaces} places'),
                    _SummaryChip(icon: Icons.auto_awesome, label: itinerary.generatedBy),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 260,
            child: Transform.rotate(
              angle: 0.03,
              child: Container(
                decoration: NavTripStyles.polaroidCard(),
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAvM2OTp2gDpKOxH_Kl-WmlyBp8GHw7-mZjEbwr8_B6HUY4UvNNGqKC6-Z7rcU_c9ZsFgVi-9wYCMyUCr_xO26X_usQChYzFsmDyA_WEMQzi-eIH3BlUOLXRTB--i5oQgIEToK8PWa-Ywq3DDAXKgnRl6OztI_LdZXmf52qrCa7OM5FuA-tPOMLXege9SPYNoCRbZT-4d0d5zuRiloVcMhJyNO48vsaDOXSe4x-q-NoLFLgjYSi-t77-PPu1i9RB5ZtOJj_Kx82vjVL',
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.day,
    required this.onViewRoute,
  });

  final ItineraryDay day;
  final VoidCallback onViewRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NavTripStyles.paperCard(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day ${day.dayNumber}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: NavTripPalette.terracottaDeep)),
              OutlinedButton.icon(onPressed: onViewRoute, icon: const Icon(Icons.route), label: const Text('View Route')),
            ],
          ),
          const SizedBox(height: 18),
          Stack(
            children: [
              Positioned(
                left: 14,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: NavTripPalette.terracotta),
              ),
              Column(
                children: [
                  for (final place in day.places) ...[
                    _TimelineItem(place: place),
                    if (place != day.places.last) const SizedBox(height: 18),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.place});

  final ItineraryPlace place;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: NavTripPalette.terracotta, width: 2),
            ),
            child: Center(
              child: Text(
                '${place.sequenceOrder}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: NavTripPalette.terracottaDeep),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffdec0b7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: NavTripPalette.terracottaDeep)),
                  const SizedBox(height: 6),
                  Text(
                    '${place.category} • ${place.estimatedVisitMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NavTripPalette.mutedInk),
                  ),
                  const SizedBox(height: 4),
                  if (place.sequenceOrder > 1)
                    Text(
                      '${place.travelDistanceKm.toStringAsFixed(1)} km from previous • about ${place.estimatedTravelMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NavTripPalette.mutedInk),
                    ),
                  const SizedBox(height: 4),
                  Text('${place.openingTime} - ${place.closingTime}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarWidgets extends StatelessWidget {
  const _SidebarWidgets();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: NavTripStyles.stickyNote(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weather', style: Theme.of(context).textTheme.headlineSmall),
                  const Icon(Icons.cloudy_snowing, color: NavTripPalette.terracotta, size: 30),
                ],
              ),
              const SizedBox(height: 14),
              _KeyValueRow(label: 'Current', value: '-2°C'),
              _KeyValueRow(label: 'Wind', value: '24 km/h'),
              const SizedBox(height: 10),
              Text('Pack layers. The wind bites today.', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: NavTripPalette.mutedInk)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          decoration: NavTripStyles.paperCard(radius: 14),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated Budget', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: NavTripPalette.terracottaDeep)),
              const SizedBox(height: 14),
              const _BudgetBar(label: 'Car & Fuel', value: r'$1,200', fraction: 0.75),
              const SizedBox(height: 12),
              const _BudgetBar(label: 'Stay', value: r'$1,800', fraction: 0.6),
              const SizedBox(height: 12),
              const _BudgetBar(label: 'Food & Misc', value: r'$800', fraction: 0.4),
              const SizedBox(height: 14),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.labelLarge),
                  Text(r'$3,800', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: NavTripPalette.terracotta)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: NavTripPalette.sand,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xff8b716a), style: BorderStyle.solid),
          ),
          padding: const EdgeInsets.all(18),
          child: Text(
            'Remember to download offline maps for the Eastfjords. Signal can be spotty between the mountain passes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: NavTripPalette.mutedInk),
          ),
        ),
      ],
    );
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar({
    required this.label,
    required this.value,
    required this.fraction,
  });

  final String label;
  final String value;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: fraction,
            backgroundColor: NavTripPalette.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation(NavTripPalette.terracotta),
          ),
        ),
      ],
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xffdec0b7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: NavTripPalette.terracotta),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}




