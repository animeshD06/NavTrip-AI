import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tourist_place.dart';
import '../providers/trip_planner_controller.dart';
import '../theme/navtrip_theme.dart';
import 'itinerary_screen.dart';
import 'tourist_map_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TripPlannerController>().initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TripPlannerController>();
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 960;
    final places = controller.places.isEmpty ? _samplePlaces : controller.places;

    return Scaffold(
      body: PaperTexture(
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(
                  width < 600 ? 20 : 64,
                  0,
                  width < 600 ? 20 : 64,
                  110,
                ),
                children: [
                  _TopBar(onSignIn: () => Navigator.of(context).pushNamed('/login')),
                  const SizedBox(height: 28),
                  _WelcomeHeader(
                    destination: controller.destination,
                    connected: controller.backendConnected,
                    status: controller.backendStatus,
                    onReconnect: controller.isCheckingBackend ? null : () async {
                      await controller.checkBackend();
                      if (controller.backendConnected) {
                        await controller.loadPlaces();
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  _SpotlightCard(
                    onViewItinerary: () => _goToItinerary(context, controller),
                    onEditNotes: () => _toast('Notes editor preview'),
                  ),
                  const SizedBox(height: 28),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _PinboardSection(places: places, onOpenMap: (place) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TouristMapScreen(initialPlace: place))))),
                        const SizedBox(width: 24),
                        SizedBox(width: 340, child: _TimelineAndMapSection(onOpenTrip: () => Navigator.of(context).pushNamed('/trip-details'), onOpenMap: () => Navigator.of(context).pushNamed('/trip-map'))),
                      ],
                    )
                  else ...[
                    _PinboardSection(places: places, onOpenMap: (place) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TouristMapScreen(initialPlace: place)))),
                    const SizedBox(height: 24),
                    _TimelineAndMapSection(onOpenTrip: () => Navigator.of(context).pushNamed('/trip-details'), onOpenMap: () => Navigator.of(context).pushNamed('/trip-map')),
                  ],
                ],
              ),
              if (!isDesktop)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: _MobileNavBar(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goToItinerary(BuildContext context, TripPlannerController controller) async {
    if (controller.itinerary == null) {
      await controller.generateItinerary();
    }
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ItineraryScreen()));
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('NavTrip-AI', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: NavTripPalette.terracottaDeep, fontSize: MediaQuery.sizeOf(context).width < 600 ? 34 : 44)),
        TextButton(onPressed: onSignIn, child: const Text('Sign In')),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.destination,
    required this.connected,
    required this.status,
    required this.onReconnect,
  });

  final String destination;
  final bool connected;
  final String status;
  final VoidCallback? onReconnect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome Back, Julian', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: NavTripPalette.terracotta, fontSize: MediaQuery.sizeOf(context).width < 600 ? 36 : 54)),
        const SizedBox(height: 8),
        Text(
          '"Not all those who wander are lost, but some need a better map."',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: NavTripPalette.mutedInk, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatusPill(
              label: connected ? 'Backend connected' : 'Backend offline',
              icon: connected ? Icons.cloud_done : Icons.cloud_off,
            ),
            _StatusPill(label: 'Planning for $destination', icon: Icons.place),
            _StatusPill(label: status, icon: Icons.info_outline),
            if (onReconnect != null)
              ActionChip(
                avatar: const Icon(Icons.refresh, size: 16),
                label: const Text('Reconnect'),
                onPressed: onReconnect,
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xffdec0b7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: NavTripPalette.terracotta),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({
    required this.onViewItinerary,
    required this.onEditNotes,
  });

  final VoidCallback onViewItinerary;
  final VoidCallback onEditNotes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: NavTripStyles.paperCard(radius: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: NavTripPalette.terracotta,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text('Today\'s Spotlight', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                ),
                const SizedBox(height: 16),
                Text('Autumn in the Scottish Highlands', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: NavTripPalette.terracottaDeep, fontSize: 34)),
                const SizedBox(height: 12),
                Text(
                  'Your itinerary is looking spectacular. We\'ve surfaced a few hidden stops and a route note you can open from the trip map.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: NavTripPalette.mutedInk),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(onPressed: onViewItinerary, child: const Text('View Itinerary')),
                    OutlinedButton(onPressed: onEditNotes, child: const Text('Edit Notes')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 320,
            child: Transform.rotate(
              angle: 0.03,
              child: Container(
                decoration: NavTripStyles.polaroidCard(),
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDcaoykP8GYJS_PcuSy8Z5MsdQsfRP5yoxYavgicUHxgiD9cY-kKxCGaeJ80z8PcKWBkPt6fK-g6LRz4Xd_j00E3JzmVbHqdrgAMch51pDNPPP2u3nv0YOJXPIiGGKQv46huMOLX4Pd9Bz7PUm4sm92jVpgxpOB8KK3yJKmzkvQsKChf-ZWkQtN7iW48uYkhqcQRFoMVrWTl2jq-c9vaPAep-tUYAGNmGeLHep1xowOWr92tBZMxvrRhUnOPsWTOkTzNsZwBU9TRK0i',
                    height: 320,
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

class _PinboardSection extends StatelessWidget {
  const _PinboardSection({
    required this.places,
    required this.onOpenMap,
  });

  final List<TouristPlace> places;
  final ValueChanged<TouristPlace> onOpenMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Pinboard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: NavTripPalette.mutedInk)),
            TextButton(onPressed: () => Navigator.of(context).pushNamed('/trip-details'), child: const Text('See all trips')),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width < 720 ? 1 : 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.92,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _TripCard(
              image:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC9NmwaW7BBkFcjJs8MRalpoUSctS9aLxf9A3z0nKoReBW6owD2T57Cr4fukvl-Z90Rsm-ZMfmo46uAcPrscRM4-rPZKH0OSOC-sArA8lzEjrMl2-jh0o6EL9mRwDpPMiO6gQDNPSzQRfSAEmXc8KFOx6f5SJ62PPPgaBc3u4dxLVgMLFG6BGrN0d20ep7a_yOg95k3mWJ1ZWmWzDl5A-yBvoOK3JUXOy2DT4jEXQ4hZijrYtT55DvpdiQRyt39fUuW2UodoJOrc1-f',
              date: 'OCT 12',
              title: 'Roman Escapade',
              subtitle: 'Italy � 5 Days',
              footer: '32 PINNED SPOTS',
              onTap: () => Navigator.of(context).pushNamed('/trip-details'),
            ),
            _TripCard(
              image:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCjHVtVcf5pUDBcddizpfb9nfeINpnEgWtrq-HMvA2aD9ilQLk2IsmkcNVpoR08XvpsdVQ93Zl5SEY9fqqK8VToD0RZEBQu97rr12Efx8ZdeWll2Vq24cjhYhBJDSDi_9pZf-mpsPv22b-kppUQxidiU5nagOOC6v9lpSQMTa4qO0hjEKR929OAY4m4sn-IstAgDZsEZNlA8E2lE5w_5Ca53MUkcXnfWSnQG-P6s1C1B-LJkpGCp5W88q52MSVtroABrxBuVBSNr1Ie',
              date: 'NOV 04',
              title: 'Kyoto Serenity',
              subtitle: 'Japan � 12 Days',
              footer: '14 PINNED SPOTS',
              onTap: () => onOpenMap(places.first),
            ),
            _StickyDraftCard(onTap: () => Navigator.of(context).pushNamed('/dashboard')),
            _TripCard(
              image:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDqSr-jDZ3s6sJ4MHVblLt9e-M5iEWpK60asKVE_30veuVDeQXEIT3nErCK9WawEgngsA5OrM20FTWtwaDk8xx4gVQb_XnB7HB05-_JRuPaNkZpO-t4WtFNdg5Z5_zmJe7B4A3ifbPN_yRgUEVOJdZtc_mDW1aJ-M5F5SgVuBrQ7n6NpdtnQnkuHEmZxBTmmNTlGwwA1hsMlh7c48gIJjKt1F6GUNqjKMhW6_SR3vr9-rzm1P0TqzG10OxZLr_g7-mVRSPtcy-ecQWH',
              date: 'APR 27',
              title: 'Iceland Ring Road',
              subtitle: 'Iceland � 10 Days',
              footer: '9 PINNED SPOTS',
              onTap: () => Navigator.of(context).pushNamed('/trip-map'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TripCard extends StatefulWidget {
  const _TripCard({
    required this.image,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.footer,
    required this.onTap,
  });

  final String image;
  final String date;
  final String title;
  final String subtitle;
  final String footer;
  final VoidCallback onTap;

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: _hovered ? 1.02 : 1,
          child: Container(
            decoration: NavTripStyles.paperCard(radius: 2),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 400),
                          scale: _hovered ? 1.05 : 1,
                          child: Image.network(widget.image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(widget.date, style: Theme.of(context).textTheme.labelMedium),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: NavTripPalette.terracottaDeep)),
                const SizedBox(height: 4),
                Text(widget.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NavTripPalette.mutedInk)),
                const Spacer(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.footer, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: NavTripPalette.mutedInk)),
                    const Icon(Icons.more_horiz, color: NavTripPalette.mutedInk),
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

class _StickyDraftCard extends StatelessWidget {
  const _StickyDraftCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: NavTripStyles.stickyNote(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(Icons.push_pin, color: NavTripPalette.terracotta),
                Text('Draft', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 20),
            Text('Next Adventure?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            _UnderlineNote(text: 'Maybe the Patagonia trails?'),
            _UnderlineNote(text: 'Check flights for February'),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add),
              label: const Text('New Trip'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnderlineNote extends StatelessWidget {
  const _UnderlineNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dashed,
            ),
      ),
    );
  }
}

class _TimelineAndMapSection extends StatelessWidget {
  const _TimelineAndMapSection({
    required this.onOpenTrip,
    required this.onOpenMap,
  });

  final VoidCallback onOpenTrip;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: NavTripStyles.paperCard(radius: 14),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Activity', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: NavTripPalette.terracottaDeep)),
              const SizedBox(height: 20),
              _ActivityLine(time: '2 HOURS AGO', title: 'Added Old Quay Inn to Scotland Trip', body: 'Found a handwritten recommendation from a local guide.'),
              _ActivityLine(time: 'YESTERDAY', title: 'Optimized Route: Highlands to Skye', body: 'Saved 45 mins of driving time by switching mountain passes.'),
              _ActivityLine(time: 'MONDAY', title: 'Shared Kyoto with Sarah', body: 'Collaborative editing enabled for the tea house tour.'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(onPressed: onOpenTrip, child: const Text('Open Details')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 410,
          decoration: NavTripStyles.paperCard(radius: 14),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Opacity(opacity: 0.62, child: Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuDqSr-jDZ3s6sJ4MHVblLt9e-M5iEWpK60asKVE_30veuVDeQXEIT3nErCK9WawEgngsA5OrM20FTWtwaDk8xx4gVQb_XnB7HB05-_JRuPaNkZpO-t4WtFNdg5Z5_zmJe7B4A3ifbPN_yRgUEVOJdZtc_mDW1aJ-M5F5SgVuBrQ7n6NpdtnQnkuHEmZxBTmmNTlGwwA1hsMlh7c48gIJjKt1F6GUNqjKMhW6_SR3vr9-rzm1P0TqzG10OxZLr_g7-mVRSPtcy-ecQWH', fit: BoxFit.cover)),
                ),
              ),
              Positioned(
                right: 14,
                top: 14,
                child: Column(
                  children: [
                    _MapButton(icon: Icons.add),
                    const SizedBox(height: 8),
                    _MapButton(icon: Icons.remove),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: NavTripPalette.terracotta, borderRadius: BorderRadius.circular(2)),
                      child: const Text('STAY HERE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 6),
                    const Icon(Icons.location_on, color: NavTripPalette.terracotta, size: 38),
                  ],
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffdec0b7)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Current Destination', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: NavTripPalette.mutedInk)),
                          const SizedBox(height: 4),
                          Text('Portree, Highlands', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: NavTripPalette.terracottaDeep)),
                        ],
                      ),
                      TextButton(onPressed: onOpenMap, child: const Text('Expand Map')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(onPressed: () {}, icon: Icon(icon, color: NavTripPalette.terracotta)),
    );
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({
    required this.time,
    required this.title,
    required this.body,
  });

  final String time;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: NavTripPalette.terracotta, width: 2), color: Colors.white)),
              Container(width: 2, height: 58, color: NavTripPalette.terracotta),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: NavTripPalette.terracotta)),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NavTripPalette.mutedInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileNavBar extends StatelessWidget {
  const _MobileNavBar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xff3f3f3e),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.18), blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(label: 'Home', icon: Icons.home, selected: true, onTap: () {}),
            _NavItem(label: 'Explore', icon: Icons.explore, onTap: () => Navigator.of(context).pushNamed('/trip-details')),
            _FabItem(onTap: () => Navigator.of(context).pushNamed('/dashboard')),
            _NavItem(label: 'Trips', icon: Icons.map, onTap: () => Navigator.of(context).pushNamed('/trip-map')),
            _NavItem(label: 'Profile', icon: Icons.person, onTap: () => Navigator.of(context).pushNamed('/login')),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.white70, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: selected ? Colors.white : Colors.white70)),
        ],
      ),
    );
  }
}

class _FabItem extends StatelessWidget {
  const _FabItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: -30),
        decoration: const BoxDecoration(
          color: NavTripPalette.terracotta,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

final List<TouristPlace> _samplePlaces = [
  const TouristPlace(
    id: 'sample-1',
    name: 'Sunrise Cliffs',
    category: 'nature',
    latitude: 26.9124,
    longitude: 75.7873,
    description: 'A quiet first stop with a dramatic view.',
    city: 'Jaipur',
    state: 'Rajasthan',
    rating: 4.7,
    openingTime: '06:00',
    closingTime: '18:00',
  ),
  const TouristPlace(
    id: 'sample-2',
    name: 'Old City Walk',
    category: 'historical',
    latitude: 26.9200,
    longitude: 75.8200,
    description: 'Heritage lanes and local stories.',
    city: 'Jaipur',
    state: 'Rajasthan',
    rating: 4.6,
    openingTime: '09:00',
    closingTime: '20:00',
  ),
];




