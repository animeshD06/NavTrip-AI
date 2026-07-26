import 'package:flutter/material.dart';

import '../theme/navtrip_theme.dart';
import '../widgets/home/editorial_scroll_story.dart';
import '../widgets/home/sticky_trip_planner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.loadPlacesOnStart = false,
    super.key,
  });

  final bool loadPlacesOnStart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _stepsKey = GlobalKey();
  final _destinationsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;

    return Scaffold(
      body: PaperTexture(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopNav(
                    onExplore: () => _scrollToKey(_stepsKey),
                    onPlanner: () =>
                        Navigator.of(context).pushNamed('/dashboard'),
                    onTrips: () =>
                        Navigator.of(context).pushNamed('/trip-details'),
                    onSignIn: () => Navigator.of(context).pushNamed('/login'),
                    mobile: !isDesktop,
                  ),
                  EditorialScrollStory(
                    scrollController: _scrollController,
                    onPrimary: () =>
                        Navigator.of(context).pushNamed('/dashboard'),
                    onExplore: () => _scrollToKey(_stepsKey),
                  ),
                  KeyedSubtree(
                    key: _stepsKey,
                    child: StickyTripPlanner(
                      scrollController: _scrollController,
                      steps: _plannerSteps(),
                    ),
                  ),
                  Container(
                    key: _destinationsKey,
                    padding: EdgeInsets.symmetric(
                      horizontal: width < 600 ? 20 : 64,
                      vertical: 56,
                    ),
                    child: const _DestinationsSection(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width < 600 ? 20 : 64,
                      vertical: 12,
                    ),
                    child: _Footer(onExplore: () => _scrollToKey(_stepsKey)),
                  ),
                ],
              ),
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
    );
  }

  List<PlannerStepData> _plannerSteps() {
    return [
      PlannerStepData(
        title: 'Enter Destination',
        heading: 'Start with the place calling your name.',
        description:
            'Choose a city or region and NavTrip begins shaping the trip around local rhythm, travel time, and nearby highlights.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDRpFXG1Fa46N8fnNfSf8ICeYzNmolpXUgu4jXbP8ztVfuOIQlYaWQ6iNV-lL-GvKCz-1VceN1uB2eh1ZNZxDVL8RaP-P4-DtGfljwxFr_52MfP2aQuvwH3GXVTXStYhFHl3cgAAofRo_Pw_t7a0st6zMyVmBdIAxKaj0rrmHQxTutpbbH4Lem9BsX5FQqtUYt-QpyFJz0KicXnnpVvuYKCUktSGxKH4v9vKa2fH8nGNGjRSxAyL8C2rEbDTZLYU9irDpSphbv0vLyX',
        icon: Icons.place_outlined,
      ),
      PlannerStepData(
        title: 'Select Dates',
        heading: 'Set the pace before the route takes shape.',
        description:
            'Pick trip length and give the planner enough structure to balance full days, slow mornings, and realistic travel windows.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCriTJzsnotX5klGQPPsz_A2QTNUE-wnECnaAfcOFxBJYj4iJKEP73q6G7u_LaXEEW57asETqmQcGVE4uyLDziTXVn_7NyI3ndJNnMQbGbE36vlEgO5Tw7HXEzJI1nlbMpy2k3GeHRnEBI0C6E_wAzy5iTsqxsoKAv05n65PZ41l_n4Lk02C251yayulk-iRFDqVGPix9YrZW4kFxTXKK1QB0fmdWo8w-shbBRCpBPlXlTSRxJ7lhZQaOVog03jQ5ottDZ7rD6oXADh',
        icon: Icons.calendar_month_outlined,
      ),
      PlannerStepData(
        title: 'Choose Preferences',
        heading: 'Tell the planner what kind of traveler you are.',
        description:
            'Blend culture, nature, food, history, pace, and budget so recommendations feel personal instead of generic.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCjHVtVcf5pUDBcddizpfb9nfeINpnEgWtrq-HMvA2aD9ilQLk2IsmkcNVpoR08XvpsdVQ93Zl5SEY9fqqK8VToD0RZEBQu97rr12Efx8ZdeWll2Vq24cjhYhBJDSDi_9pZf-mpsPv22b-kppUQxidiU5nagOOC6v9lpSQMTa4qO0hjEKR929OAY4m4sn-IstAgDZsEZNlA8E2lE5w_5Ca53MUkcXnfWSnQG-P6s1C1B-LJkpGCp5W88q52MSVtroABrxBuVBSNr1Ie',
        icon: Icons.tune,
      ),
      PlannerStepData(
        title: 'AI Creates Itinerary',
        heading: 'Watch the rough idea become a real plan.',
        description:
            'NavTrip orders stops, groups nearby places, estimates visits, and keeps the route readable from breakfast to evening.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDqSr-jDZ3s6sJ4MHVblLt9e-M5iEWpK60asKVE_30veuVDeQXEIT3nErCK9WawEgngsA5OrM20FTWtwaDk8xx4gVQb_XnB7HB05-_JRuPaNkZpO-t4WtFNdg5Z5_zmJe7B4A3ifbPN_yRgUEVOJdZtc_mDW1aJ-M5F5SgVuBrQ7n6NpdtnQnkuHEmZxBTmmNTlGwwA1hsMlh7c48gIJjKt1F6GUNqjKMhW6_SR3vr9-rzm1P0TqzG10OxZLr_g7-mVRSPtcy-ecQWH',
        icon: Icons.auto_awesome,
      ),
      PlannerStepData(
        title: 'Customize Plan',
        heading: 'Refine the route until it sounds like you.',
        description:
            'Swap stops, keep notes, add hidden gems, and use map context to turn the generated draft into your own journey.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDcaoykP8GYJS_PcuSy8Z5MsdQsfRP5yoxYavgicUHxgiD9cY-kKxCGaeJ80z8PcKWBkPt6fK-g6LRz4Xd_j00E3JzmVbHqdrgAMch51pDNPPP2u3nv0YOJXPIiGGKQv46huMOLX4Pd9Bz7PUm4sm92jVpgxpOB8KK3yJKmzkvQsKChf-ZWkQtN7iW48uYkhqcQRFoMVrWTl2jq-c9vaPAep-tUYAGNmGeLHep1xowOWr92tBZMxvrRhUnOPsWTOkTzNsZwBU9TRK0i',
        icon: Icons.edit_note,
      ),
      PlannerStepData(
        title: 'Ready to Travel',
        heading: 'Carry the finished plan into the world.',
        description:
            'Open maps, review daily timing, keep offline notes close, and travel with a plan that still leaves room to wander.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAvM2OTp2gDpKOxH_Kl-WmlyBp8GHw7-mZjEbwr8_B6HUY4UvNNGqKC6-Z7rcU_c9ZsFgVi-9wYCMyUCr_xO26X_usQChYzFsmDyA_WEMQzi-eIH3BlUOLXRTB--i5oQgIEToK8PWa-Ywq3DDAXKgnRl6OztI_LdZXmf52qrCa7OM5FuA-tPOMLXege9SPYNoCRbZT-4d0d5zuRiloVcMhJyNO48vsaDOXSe4x-q-NoLFLgjYSi-t77-PPu1i9RB5ZtOJj_Kx82vjVL',
        icon: Icons.flight_takeoff,
        ctaLabel: 'Start Planning',
        onCta: () => Navigator.of(context).pushNamed('/dashboard'),
      ),
    ];
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.08,
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({
    required this.onExplore,
    required this.onPlanner,
    required this.onTrips,
    required this.onSignIn,
    required this.mobile,
  });

  final VoidCallback onExplore;
  final VoidCallback onPlanner;
  final VoidCallback onTrips;
  final VoidCallback onSignIn;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xfff9f9f8),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 64, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'NavTrip-AI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: NavTripPalette.terracottaDeep,
                  fontSize: mobile ? 34 : 44),
            ),
          ),
          if (!mobile) ...[
            const SizedBox(width: 24),
            Flexible(
              fit: FlexFit.loose,
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 18,
                runSpacing: 8,
                children: [
                  TextButton(
                      onPressed: onExplore, child: const Text('Explore')),
                  TextButton(
                      onPressed: onPlanner, child: const Text('Planner')),
                  TextButton(onPressed: onTrips, child: const Text('My Trips')),
                  FilledButton(
                    onPressed: onSignIn,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ] else
            IconButton(
              onPressed: onSignIn,
              icon:
                  const Icon(Icons.menu, color: NavTripPalette.terracottaDeep),
            ),
        ],
      ),
    );
  }
}

class _DestinationsSection extends StatelessWidget {
  const _DestinationsSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inspired Destinations',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: NavTripPalette.terracottaDeep,
                fontSize: width < 600 ? 36 : 48)),
        const SizedBox(height: 20),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: isMobile ? 1 : 4,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: isMobile ? 1.18 : 0.72,
          children: const [
            _DestinationCard(
              country: 'ITALY',
              title: 'The Amalfi Coast',
              image:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBAEXGXMZdRt9Qlfp1YXjUFUchOD7q0aHNBBCnRvcAuYkdoUCzeWjgKfpUH7_WtpKIWq8dvG1VM5W_O52FR9Q0g_nolife3sRwuNnYoQRQiWYbk44GMKwEFh7U5ffGv5BnnFAYd231PWxXpGqFkFpGzNFjwMETzYQY6ShT1bWqgxy6scPIwpMCC4cFQO_jCS1pM9Dg-odeFFuyLcfPcgI6Gn_q6_Ba9kXVl6jYoM4tdLLLQRsQqRhfEPOZANbTG5QVgKI1R7IRuu8JI',
              span: 2,
            ),
            _DestinationCard(
              country: 'NORWAY',
              title: 'Fjord Hideaways',
              image:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuB6X-nbkrD2RuSThyypMSJ4dPWmB8NvsIlabOYZCea3JqcRawYtxt6qReBvly4mX6dddRBWAxZBF7OdS0oQ2-AAwZb0PtjK0vrTw9omWqoKElBsoBmjqNiXBdDv1_nahfFPp-aydiYMQ62R5d1dapegzrtoVZwdAFYLkoI8Ve1t9_uQ0EcwO7g53WQArUSNWylmcvS34ZdISCzZydb2aFbk36j_2F0G9uLyFK_4jtDdUFMi4L6SvSTx_dNqCMErGsQRW8Tsq47iMQfA',
            ),
            _DestinationCard(
              country: 'MOROCCO',
              title: 'Marrakesh Souks',
              image:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBBj229moOMV-6SYMCNj19csS_yeumcFOAJ7PP6qcjtNgD4fc7EqpHKbCOoz193F2gnjrI5YOsbqsEXxjFpIrrXLpUt34vove7iJToc2pmbjquwKGGw_e1hSselOGnLJSefeWtEoc3TJjXoLajUtEcNgZMUl8Gyc8qSdpR_qGpboxE8g1fAHK-sH-GTroVJjE6GAxnZu_RdIqFih20EEFq3YLtlNtU4RZeZrzygD2wjLwB9Cl9eXSs6miSObNAnFuhjT6fs9tyiFVvh',
            ),
            _DestinationCard(
              country: 'JAPAN',
              title: 'Kyoto Retreat',
              image:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBhweeDqK7cfx6FGBKWhcAYPW9AkaPzgKU0rQc_AcZS4rODLP2sB9WdkWkj1yH-Y9xAAV4EXiyUDR99MubUQuqcJDOzAkH1_HmTnWg8QPEvnvVgeLjJrspwddE39R8j0n-21X1CSGuX2FWmd-TIJonqH1JVLb8hJWIRZg3cXfTbVtmWkD4vWcJG8kwTssPhkq8GvR5pxDLU6Z56Ot0N0zeMzWSOVtqCw2S0B-Fb5Sj7Saqccj3gtLTsVWASDa7_LTSWXH7SI8eMHyW7',
            ),
          ],
        ),
      ],
    );
  }
}

class _DestinationCard extends StatefulWidget {
  const _DestinationCard({
    required this.country,
    required this.title,
    required this.image,
    this.span = 1,
  });

  final String country;
  final String title;
  final String image;
  final int span;

  @override
  State<_DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<_DestinationCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _hovered ? 1.02 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 500),
                scale: _hovered ? 1.08 : 1.0,
                child: Image.network(widget.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.62)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(widget.country,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(widget.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NavTrip-AI',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: NavTripPalette.terracottaDeep)),
        const SizedBox(height: 6),
        Text(
          'A travel planner shaped like a story.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: NavTripPalette.mutedInk),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffdec0b7), width: 1)),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                brand,
                const SizedBox(height: 12),
                TextButton(
                    onPressed: onExplore, child: const Text('Jump to steps')),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: brand),
                const SizedBox(width: 24),
                TextButton(
                    onPressed: onExplore, child: const Text('Jump to steps')),
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
                                  .pushNamed('/dashboard'))),
                      const SizedBox(width: 64),
                      Expanded(
                          child: _NavItem(
                              label: 'Trips',
                              icon: Icons.map,
                              onTap: () => Navigator.of(context)
                                  .pushNamed('/trip-details'))),
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
