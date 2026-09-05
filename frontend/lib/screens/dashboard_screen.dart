import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tourist_place.dart';
import '../providers/auth_provider.dart';
import '../models/itinerary.dart';
import '../providers/trip_planner_controller.dart';
import '../theme/navtrip_theme.dart';
import '../widgets/home/travel_stack_scroller.dart';
import '../widgets/home/trip_location_and_details_sheet.dart';
import 'tourist_map_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scrollController = ScrollController();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final controller = context.watch<TripPlannerController>();
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 960;
    final places =
        controller.places.isEmpty ? _samplePlaces : controller.places;

    return Scaffold(
      body: PaperTexture(
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  width < 600 ? 20 : 64,
                  0,
                  width < 600 ? 20 : 64,
                  110,
                ),
                children: [
                  _TopBar(
                    auth: auth,
                    controller: controller,
                    onSignIn: () => Navigator.of(context).pushNamed('/login'),
                    onProfile: () => _showProfileMenu(context, auth),
                    onSelectLocation: () =>
                        TripLocationAndDetailsSheet.show(context),
                  ),
                  if (controller.isLoading ||
                      controller.errorMessage != null ||
                      controller.infoMessage != null) ...[
                    const SizedBox(height: 14),
                    _PlannerStatusBanner(controller: controller),
                  ],
                  const SizedBox(height: 28),
                  TravelStackScroller(
                    scrollController: _scrollController,
                    desktopHeightFactor: 1.15,
                    cards: _dashboardStackCards(
                      auth: auth,
                      controller: controller,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _PinboardSection(
                            controller: controller,
                            places: places,
                            onOpenMap: (place) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    TouristMapScreen(initialPlace: place),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 340,
                          child: _TimelineAndMapSection(
                            controller: controller,
                            onOpenTrip: () => Navigator.of(context)
                                .pushNamed('/trip-details'),
                            onOpenMap: () =>
                                Navigator.of(context).pushNamed('/trip-map'),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _PinboardSection(
                      controller: controller,
                      places: places,
                      onOpenMap: (place) => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TouristMapScreen(initialPlace: place),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _TimelineAndMapSection(
                      controller: controller,
                      onOpenTrip: () =>
                          Navigator.of(context).pushNamed('/trip-details'),
                      onOpenMap: () =>
                          Navigator.of(context).pushNamed('/trip-map'),
                    ),
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

  List<TravelStackCardData> _dashboardStackCards({
    required AuthProvider auth,
    required TripPlannerController controller,
  }) {
    final userName = auth.currentUser?.displayName ?? 'Traveler';
    final destination = controller.destination;
    final statusChips = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _StatusPill(
          label: controller.backendConnected
              ? 'Backend connected'
              : 'Backend offline',
          icon:
              controller.backendConnected ? Icons.cloud_done : Icons.cloud_off,
        ),
        _StatusPill(
            label: 'Destination: $destination (${controller.days} Days)',
            icon: Icons.place),
        _StatusPill(
            label: 'Vibe: ${controller.category.toUpperCase()}',
            icon: Icons.tune),
        ActionChip(
          avatar: const Icon(Icons.edit_location_alt_outlined,
              size: 16, color: NavTripPalette.terracotta),
          label: const Text('Change Location & Vibe'),
          onPressed: () => TripLocationAndDetailsSheet.show(context),
        ),
        if (!controller.isCheckingBackend)
          ActionChip(
            avatar: const Icon(Icons.refresh, size: 16),
            label: const Text('Reconnect'),
            onPressed: () async {
              await controller.checkBackend();
              if (controller.backendConnected) {
                await controller.loadPlaces();
              }
            },
          ),
      ],
    );

    return [
      TravelStackCardData(
        badge: 'DASHBOARD',
        title: 'Welcome Back, $userName',
        subtitle:
            'Planning for $destination. Your trips, notes, pins, and route ideas are gathered into one calm planning desk.',
        quote: 'Not all those who wander are lost, but some need a better map.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDcaoykP8GYJS_PcuSy8Z5MsdQsfRP5yoxYavgicUHxgiD9cY-kKxCGaeJ80z8PcKWBkPt6fK-g6LRz4Xd_j00E3JzmVbHqdrgAMch51pDNPPP2u3nv0YOJXPIiGGKQv46huMOLX4Pd9Bz7PUm4sm92jVpgxpOB8KK3yJKmzkvQsKChf-ZWkQtN7iW48uYkhqcQRFoMVrWTl2jq-c9vaPAep-tUYAGNmGeLHep1xowOWr92tBZMxvrRhUnOPsWTOkTzNsZwBU9TRK0i',
        trailing: statusChips,
      ),
      TravelStackCardData(
        badge: 'TODAY\'S SPOTLIGHT',
        title: '$destination Itinerary (${controller.days} Days)',
        subtitle:
            'Your travel schedule for $destination is ready. Custom stops, route notes, and map context are balanced for your pace.',
        quote: 'A road becomes a story when the stops are chosen with care.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC9NmwaW7BBkFcjJs8MRalpoUSctS9aLxf9A3z0nKoReBW6owD2T57Cr4fukvl-Z90Rsm-ZMfmo46uAcPrscRM4-rPZKH0OSOC-sArA8lzEjrMl2-jh0o6EL9mRwDpPMiO6gQDNPSzQRfSAEmXc8KFOx6f5SJ62PPPgaBc3u4dxLVgMLFG6BGrN0d20ep7a_yOg95k3mWJ1ZWmWzDl5A-yBvoOK3JUXOy2DT4jEXQ4hZijrYtT55DvpdiQRyt39fUuW2UodoJOrc1-f',
        primaryLabel: 'View Itinerary',
        onPrimary: () => _goToItinerary(context, controller),
        secondaryLabel: 'Change Location',
        onSecondary: () => TripLocationAndDetailsSheet.show(context),
      ),
      TravelStackCardData(
        badge: 'SMART PINBOARD',
        title: 'Places in $destination and inspired routes.',
        subtitle:
            'Keep inspiration close, then open each place on the map when it is time to turn pins into movement.',
        quote: 'Collect places like postcards, then arrange them like a day.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCjHVtVcf5pUDBcddizpfb9nfeINpnEgWtrq-HMvA2aD9ilQLk2IsmkcNVpoR08XvpsdVQ93Zl5SEY9fqqK8VToD0RZEBQu97rr12Efx8ZdeWll2Vq24cjhYhBJDSDi_9pZf-mpsPv22b-kppUQxidiU5nagOOC6v9lpSQMTa4qO0hjEKR929OAY4m4sn-IstAgDZsEZNlA8E2lE5w_5Ca53MUkcXnfWSnQG-P6s1C1B-LJkpGCp5W88q52MSVtroABrxBuVBSNr1Ie',
        primaryLabel: 'Open Trip Map',
        onPrimary: () => Navigator.of(context).pushNamed('/trip-map'),
      ),
      TravelStackCardData(
        badge: 'READY TO MOVE',
        title: 'Open the plan, adjust the day, keep traveling.',
        subtitle:
            'Use the dashboard as a living travel desk: itinerary, map, notes, budget, and timing all close at hand.',
        quote: 'The plan should support the trip, never steal the view.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAvM2OTp2gDpKOxH_Kl-WmlyBp8GHw7-mZjEbwr8_B6HUY4UvNNGqKC6-Z7rcU_c9ZsFgVi-9wYCMyUCr_xO26X_usQChYzFsmDyA_WEMQzi-eIH3BlUOLXRTB--i5oQgIEToK8PWa-Ywq3DDAXKgnRl6OztI_LdZXmf52qrCa7OM5FuA-tPOMLXege9SPYNoCRbZT-4d0d5zuRiloVcMhJyNO48vsaDOXSe4x-q-NoLFLgjYSi-t77-PPu1i9RB5ZtOJj_Kx82vjVL',
        primaryLabel: 'View Itinerary',
        onPrimary: () => _goToItinerary(context, controller),
        secondaryLabel: 'Open Map',
        onSecondary: () => Navigator.of(context).pushNamed('/trip-map'),
      ),
    ];
  }

  Future<void> _goToItinerary(
      BuildContext context, TripPlannerController controller) async {
    if (controller.itinerary == null) {
      await controller.generateItinerary();
    }
    if (!context.mounted) {
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ItineraryScreen()));
  }

  Future<void> _showProfileMenu(BuildContext context, AuthProvider auth) async {
    final user = auth.currentUser;
    if (user == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile',
                  style: Theme.of(sheetContext).textTheme.headlineMedium),
              const SizedBox(height: 16),
              _ProfileInfoRow(label: 'User ID', value: user.id),
              const SizedBox(height: 10),
              _ProfileInfoRow(
                  label: 'Username',
                  value: user.username.isEmpty ? 'Not set' : user.username),
              const SizedBox(height: 10),
              _ProfileInfoRow(
                  label: 'Email',
                  value: user.email.isEmpty ? 'Not set' : user.email),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await auth.signOut();
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.auth,
    required this.controller,
    required this.onSignIn,
    required this.onProfile,
    required this.onSelectLocation,
  });

  final AuthProvider auth;
  final TripPlannerController controller;
  final VoidCallback onSignIn;
  final VoidCallback onProfile;
  final VoidCallback onSelectLocation;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 720;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NavTrip-AI',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: NavTripPalette.terracottaDeep,
                    fontSize: isCompact ? 30 : 44,
                  ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onSelectLocation,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10 : 14,
                  vertical: isCompact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: NavTripPalette.terracotta.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(154, 52, 18, 0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place,
                        size: 16, color: NavTripPalette.terracotta),
                    const SizedBox(width: 6),
                    Text(
                      controller.destination,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: NavTripPalette.ink,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${controller.days}D)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: NavTripPalette.mutedInk,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: NavTripPalette.terracotta,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (!isCompact)
              FilledButton.icon(
                onPressed: onSelectLocation,
                style: FilledButton.styleFrom(
                  backgroundColor: NavTripPalette.terracotta,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.travel_explore, size: 18),
                label: const Text('Plan Trip'),
              ),
            if (!isCompact) const SizedBox(width: 10),
            auth.isAuthenticated
                ? OutlinedButton.icon(
                    onPressed: onProfile,
                    icon: const Icon(Icons.person_outline),
                    label: Text(
                      isCompact
                          ? (auth.currentUser?.displayName.split(' ').first ??
                              'Profile')
                          : (auth.currentUser?.displayName ?? 'Profile'),
                    ),
                  )
                : TextButton(onPressed: onSignIn, child: const Text('Sign In')),
          ],
        ),
      ],
    );
  }
}

class _PinboardSection extends StatelessWidget {
  const _PinboardSection({
    required this.controller,
    required this.places,
    required this.onOpenMap,
  });

  final TripPlannerController controller;
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
            Text('Your Pinboard',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: NavTripPalette.mutedInk)),
            TextButton.icon(
              onPressed: () => TripLocationAndDetailsSheet.show(context),
              icon: const Icon(Icons.add_location_alt_outlined, size: 18),
              label: const Text('Add / Plan New'),
            ),
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
              date: 'ACTIVE',
              title: 'Roman Escapade',
              subtitle: 'Italy • 5 Days • Heritage',
              footer: 'TAP TO PLAN ROME',
              onTap: () async {
                await controller.selectPresetDestination('Rome',
                    newCategory: 'historical', newDays: 5);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Switched destination to Rome! Generated custom itinerary.')),
                  );
                }
              },
            ),
            _TripCard(
              image:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCjHVtVcf5pUDBcddizpfb9nfeINpnEgWtrq-HMvA2aD9ilQLk2IsmkcNVpoR08XvpsdVQ93Zl5SEY9fqqK8VToD0RZEBQu97rr12Efx8ZdeWll2Vq24cjhYhBJDSDi_9pZf-mpsPv22b-kppUQxidiU5nagOOC6v9lpSQMTa4qO0hjEKR929OAY4m4sn-IstAgDZsEZNlA8E2lE5w_5Ca53MUkcXnfWSnQG-P6s1C1B-LJkpGCp5W88q52MSVtroABrxBuVBSNr1Ie',
              date: 'ACTIVE',
              title: 'Kyoto Serenity',
              subtitle: 'Japan • 4 Days • Culture',
              footer: 'TAP TO PLAN KYOTO',
              onTap: () async {
                await controller.selectPresetDestination('Kyoto',
                    newCategory: 'historical', newDays: 4);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Switched destination to Kyoto! Generated custom itinerary.')),
                  );
                }
              },
            ),
            _StickyDraftCard(
              onTap: () => TripLocationAndDetailsSheet.show(context),
            ),
            _TripCard(
              image:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDqSr-jDZ3s6sJ4MHVblLt9e-M5iEWpK60asKVE_30veuVDeQXEIT3nErCK9WawEgngsA5OrM20FTWtwaDk8xx4gVQb_XnB7HB05-_JRuPaNkZpO-t4WtFNdg5Z5_zmJe7B4A3ifbPN_yRgUEVOJdZtc_mDW1aJ-M5F5SgVuBrQ7n6NpdtnQnkuHEmZxBTmmNTlGwwA1hsMlh7c48gIJjKt1F6GUNqjKMhW6_SR3vr9-rzm1P0TqzG10OxZLr_g7-mVRSPtcy-ecQWH',
              date: 'ACTIVE',
              title: 'Iceland Ring Road',
              subtitle: 'Iceland • 7 Days • Adventure',
              footer: 'TAP TO PLAN ICELAND',
              onTap: () async {
                await controller.selectPresetDestination('Iceland Ring Road',
                    newCategory: 'adventure', newDays: 7);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Switched destination to Iceland Ring Road!')),
                  );
                }
              },
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
                          child: Image.network(widget.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink()),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(widget.date,
                            style: Theme.of(context).textTheme.labelMedium),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: NavTripPalette.terracottaDeep)),
                const SizedBox(height: 4),
                Text(widget.subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: NavTripPalette.mutedInk)),
                const Spacer(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.footer,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: NavTripPalette.mutedInk)),
                    const Icon(Icons.more_horiz,
                        color: NavTripPalette.mutedInk),
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
        decoration: NavTripStyles.stickyNote(context: context),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.push_pin,
                color: NavTripPalette.terracotta, size: 24),
            const SizedBox(height: 12),
            Text(
              'Drafting Ideas',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: NavTripPalette.terracottaDeep),
            ),
            const SizedBox(height: 8),
            Text(
              'Looking to explore somewhere new? Tap to open the trip location and details menu to choose from 10+ curated destinations or plan custom journeys worldwide.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: NavTripPalette.mutedInk),
            ),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: onTap,
              icon: const Icon(Icons.tune, size: 16),
              label: const Text('Choose Destination'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineAndMapSection extends StatelessWidget {
  const _TimelineAndMapSection({
    required this.controller,
    required this.onOpenTrip,
    required this.onOpenMap,
  });

  final TripPlannerController controller;
  final VoidCallback onOpenTrip;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: NavTripStyles.paperCard(context: context, radius: 14),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Activity',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: NavTripPalette.terracottaDeep)),
              const SizedBox(height: 20),
              _ActivityLine(
                  time: 'LOCAL CACHE',
                  title:
                      '${controller.cachedTrips.length} saved offline ${controller.cachedTrips.length == 1 ? 'trip' : 'trips'}',
                  body: controller.offlineTripLoaded
                      ? 'The latest cached itinerary is active because the backend is unavailable.'
                      : 'Generated itineraries are saved locally after each successful plan.'),
              const SizedBox(height: 8),
              _ActivityLine(
                  time: '2 HOURS AGO',
                  title: 'Added Old Quay Inn to Scotland Trip',
                  body:
                      'Found a handwritten recommendation from a local guide.'),
              _ActivityLine(
                  time: 'YESTERDAY',
                  title: 'Optimized Route: Highlands to Skye',
                  body:
                      'Saved 45 mins of driving time by switching mountain passes.'),
              _ActivityLine(
                  time: 'MONDAY',
                  title: 'Shared Kyoto with Sarah',
                  body:
                      'Collaborative editing enabled for the tea house tour.'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                    onPressed: onOpenTrip, child: const Text('Open Details')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 410,
          decoration: NavTripStyles.paperCard(context: context, radius: 14),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Opacity(
                    opacity: 0.62,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDqSr-jDZ3s6sJ4MHVblLt9e-M5iEWpK60asKVE_30veuVDeQXEIT3nErCK9WawEgngsA5OrM20FTWtwaDk8xx4gVQb_XnB7HB05-_JRuPaNkZpO-t4WtFNdg5Z5_zmJe7B4A3ifbPN_yRgUEVOJdZtc_mDW1aJ-M5F5SgVuBrQ7n6NpdtnQnkuHEmZxBTmmNTlGwwA1hsMlh7c48gIJjKt1F6GUNqjKMhW6_SR3vr9-rzm1P0TqzG10OxZLr_g7-mVRSPtcy-ecQWH',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: NavTripPalette.terracotta,
                          borderRadius: BorderRadius.circular(2)),
                      child: const Text('STAY HERE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 6),
                    const Icon(Icons.location_on,
                        color: NavTripPalette.terracotta, size: 38),
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
                          Text('Current Destination',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: NavTripPalette.mutedInk)),
                          const SizedBox(height: 4),
                          Text(controller.destination,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: NavTripPalette.terracottaDeep)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Change Destination',
                            onPressed: () =>
                                TripLocationAndDetailsSheet.show(context),
                            icon: const Icon(Icons.edit_location_alt_outlined,
                                size: 20, color: NavTripPalette.terracotta),
                          ),
                          TextButton(
                              onPressed: onOpenMap,
                              child: const Text('Expand Map')),
                        ],
                      ),
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
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(
          onPressed: () {}, icon: Icon(icon, color: NavTripPalette.terracotta)),
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
              Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: NavTripPalette.terracotta, width: 2),
                      color: Colors.white)),
              Container(width: 2, height: 58, color: NavTripPalette.terracotta),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: NavTripPalette.terracotta)),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: NavTripPalette.mutedInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlannerStatusBanner extends StatelessWidget {
  const _PlannerStatusBanner({required this.controller});

  final TripPlannerController controller;

  @override
  Widget build(BuildContext context) {
    final isError = controller.errorMessage != null;
    final message = controller.isLoading
        ? 'Working on your trip...'
        : controller.errorMessage ?? controller.infoMessage ?? '';
    final icon = controller.isLoading
        ? Icons.hourglass_top
        : isError
            ? Icons.error_outline
            : Icons.offline_pin_outlined;
    final color = isError
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.secondaryContainer;
    final foreground = isError
        ? Theme.of(context).colorScheme.onErrorContainer
        : Theme.of(context).colorScheme.onSecondaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (controller.isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            )
          else
            Icon(icon, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

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
          child: itinerary == null
              ? _emptyState(context, controller)
              : _detailsLayout(context, itinerary),
        ),
      ),
    );
  }

  Widget _detailsLayout(BuildContext context, Itinerary itinerary) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 980;
    final currentDay = itinerary
        .days[_selectedDayIndex.clamp(0, itinerary.days.length - 1).toInt()];

    return Column(
      children: [
        _HeaderBar(destination: itinerary.destination),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                width < 600 ? 20 : 64, 0, width < 600 ? 20 : 64, 20),
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
                      onSelected: (_) =>
                          setState(() => _selectedDayIndex = index),
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
                    Expanded(
                        child: _TimelineCard(
                            day: currentDay,
                            onViewRoute: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => TouristMapScreen(
                                        routeDay: currentDay))))),
                    const SizedBox(width: 24),
                    const SizedBox(width: 320, child: _SidebarWidgets()),
                  ],
                )
              else ...[
                const _SidebarWidgets(),
                const SizedBox(height: 16),
                _TimelineCard(
                    day: currentDay,
                    onViewRoute: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                TouristMapScreen(routeDay: currentDay)))),
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
            decoration: NavTripStyles.paperCard(context: context, radius: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.route,
                    size: 54, color: NavTripPalette.terracotta),
                const SizedBox(height: 12),
                Text('No itinerary generated yet.',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Create one from the dashboard or choose another destination to see the journal-style timeline here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: NavTripPalette.mutedInk),
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
                      onPressed: () =>
                          TripLocationAndDetailsSheet.show(context),
                      child: const Text('Change Location & Vibe'),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/dashboard'),
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
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 680;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 64, vertical: 16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Back to Dashboard',
                icon: const Icon(Icons.arrow_back,
                    color: NavTripPalette.terracottaDeep),
                onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
              ),
              const SizedBox(width: 8),
              Text('NavTrip-AI',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: NavTripPalette.terracottaDeep,
                      fontSize: isCompact ? 28 : 40)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () => TripLocationAndDetailsSheet.show(context),
                icon: const Icon(Icons.edit_location_alt_outlined, size: 16),
                label: Text(isCompact ? 'Change' : 'Change Location / Vibe'),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NavTripPalette.terracotta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(destination,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: NavTripPalette.terracottaDeep,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
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
      decoration: NavTripStyles.paperCard(context: context, radius: 12),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itinerary.destination,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: NavTripPalette.terracotta, fontSize: 54)),
                const SizedBox(height: 10),
                Text(
                  'A ${itinerary.days.length}-day odyssey through curated stops, travel notes, and route detail.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: NavTripPalette.mutedInk),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SummaryChip(
                        icon: Icons.calendar_month,
                        label: '${itinerary.days.length} days'),
                    _SummaryChip(
                        icon: Icons.place,
                        label: '${itinerary.totalPlaces} places'),
                    _SummaryChip(
                        icon: Icons.auto_awesome, label: itinerary.generatedBy),
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
                decoration: NavTripStyles.polaroidCard(context: context),
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
      decoration: NavTripStyles.paperCard(context: context, radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day ${day.dayNumber}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: NavTripPalette.terracottaDeep)),
              OutlinedButton.icon(
                  onPressed: onViewRoute,
                  icon: const Icon(Icons.route),
                  label: const Text('View Route')),
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
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: NavTripPalette.terracottaDeep),
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
                  Text(place.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: NavTripPalette.terracottaDeep)),
                  const SizedBox(height: 6),
                  Text(
                    '${place.category} • ${place.estimatedVisitMinutes} min',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: NavTripPalette.mutedInk),
                  ),
                  const SizedBox(height: 4),
                  if (place.sequenceOrder > 1)
                    Text(
                      '${place.travelDistanceKm.toStringAsFixed(1)} km from previous • about ${place.estimatedTravelMinutes} min',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: NavTripPalette.mutedInk),
                    ),
                  const SizedBox(height: 4),
                  Text('${place.openingTime} - ${place.closingTime}',
                      style: Theme.of(context).textTheme.bodySmall),
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
          decoration: NavTripStyles.stickyNote(context: context),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weather',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const Icon(Icons.cloudy_snowing,
                      color: NavTripPalette.terracotta, size: 30),
                ],
              ),
              const SizedBox(height: 14),
              const _KeyValueRow(label: 'Current', value: '22°C Mild'),
              const _KeyValueRow(label: 'Wind', value: '14 km/h'),
              const SizedBox(height: 10),
              Text('Great exploration conditions today.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: NavTripPalette.mutedInk)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          decoration: NavTripStyles.paperCard(context: context, radius: 14),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated Budget',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: NavTripPalette.terracottaDeep)),
              const SizedBox(height: 14),
              const _BudgetBar(
                  label: 'Activities & Visits', value: r'$350', fraction: 0.65),
              const SizedBox(height: 12),
              const _BudgetBar(
                  label: 'Stay & Hotels', value: r'$580', fraction: 0.8),
              const SizedBox(height: 12),
              const _BudgetBar(
                  label: 'Food & Local Dining', value: r'$240', fraction: 0.45),
              const SizedBox(height: 14),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Estimated',
                      style: Theme.of(context).textTheme.labelLarge),
                  Text(r'$1,170',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: NavTripPalette.terracotta)),
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
            border: Border.all(
                color: const Color(0xff8b716a), style: BorderStyle.solid),
          ),
          padding: const EdgeInsets.all(18),
          child: Text(
            'Keep offline maps handy for remote trails and viewpoints. Most cultural monuments offer audio guides on-site.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic, color: NavTripPalette.mutedInk),
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

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: NavTripPalette.mutedInk,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SelectableText(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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

class _MobileNavBar extends StatelessWidget {
  const _MobileNavBar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.9,
          height: 92,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xff3f3f3e),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.18),
                          blurRadius: 20,
                          offset: Offset(0, 10)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: _NavItem(
                              label: 'Home',
                              icon: Icons.home,
                              selected: true,
                              onTap: () {})),
                      Expanded(
                          child: _NavItem(
                              label: 'Explore',
                              icon: Icons.explore,
                              onTap: () => Navigator.of(context)
                                  .pushNamed('/trip-details'))),
                      const SizedBox(width: 64),
                      Expanded(
                          child: _NavItem(
                              label: 'Trips',
                              icon: Icons.map,
                              onTap: () => Navigator.of(context)
                                  .pushNamed('/trip-map'))),
                      Expanded(
                          child: _NavItem(
                              label: 'Profile',
                              icon: Icons.person,
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/login'))),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: _FabItem(
                    onTap: () => Navigator.of(context).pushNamed('/dashboard')),
              ),
            ],
          ),
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
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.white70),
          ),
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
        decoration: const BoxDecoration(
          color: NavTripPalette.terracotta,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                blurRadius: 18,
                offset: Offset(0, 8)),
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
