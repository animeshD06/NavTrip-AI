import 'package:flutter/material.dart';

import '../theme/navtrip_theme.dart';

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
  bool _stickyHover = false;

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
                    onPlanner: () => Navigator.of(context).pushNamed('/dashboard'),
                    onTrips: () => Navigator.of(context).pushNamed('/trip-details'),
                    onSignIn: () => Navigator.of(context).pushNamed('/login'),
                    mobile: !isDesktop,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width < 600 ? 20 : 64,
                      vertical: width < 600 ? 28 : 56,
                    ),
                    child: _HeroSection(
                      stickyHover: _stickyHover,
                      onStickyHoverChanged: (value) {
                        if (mounted) {
                          setState(() => _stickyHover = value);
                        }
                      },
                      onPrimaryAction: () => Navigator.of(context).pushNamed('/dashboard'),
                      onSecondaryAction: () => _scrollToKey(_stepsKey),
                    ),
                  ),
                  Container(
                    key: _stepsKey,
                    padding: EdgeInsets.symmetric(
                      horizontal: width < 600 ? 20 : 64,
                      vertical: 48,
                    ),
                    color: NavTripPalette.surfaceContainerLow,
                    child: const _JourneyStepsSection(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('NavTrip-AI', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: NavTripPalette.terracottaDeep, fontSize: mobile ? 34 : 44)),
          if (!mobile)
            Row(
              children: [
                TextButton(onPressed: onExplore, child: const Text('Explore')),
                const SizedBox(width: 18),
                TextButton(onPressed: onPlanner, child: const Text('Planner')),
                const SizedBox(width: 18),
                TextButton(onPressed: onTrips, child: const Text('My Trips')),
                const SizedBox(width: 18),
                FilledButton(
                  onPressed: onSignIn,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            )
          else
            IconButton(
              onPressed: onSignIn,
              icon: const Icon(Icons.menu, color: NavTripPalette.terracottaDeep),
            ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.stickyHover,
    required this.onStickyHoverChanged,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  final bool stickyHover;
  final ValueChanged<bool> onStickyHoverChanged;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 900;

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: narrow ? double.infinity : (width - 128) * 0.48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan your next adventure with precision.',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: NavTripPalette.terracottaDeep,
                      fontSize: width < 600 ? 40 : 60,
                      height: 0.98,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                'A tactile travel planner that feels like a cherished journal. Build routes, keep notes, and move from inspiration to itinerary with a few deliberate gestures.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: NavTripPalette.mutedInk,
                    ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  FilledButton(
                    onPressed: onPrimaryAction,
                    child: const Text('Start Planning'),
                  ),
                  OutlinedButton(
                    onPressed: onSecondaryAction,
                    child: const Text('How it works'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: narrow ? double.infinity : (width - 128) * 0.42,
          child: Column(
            children: [
              MouseRegion(
                onEnter: (_) => onStickyHoverChanged(true),
                onExit: (_) => onStickyHoverChanged(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  transform: Matrix4.rotationZ(stickyHover ? 0.02 : 0.05),
                  child: Container(
                    decoration: NavTripStyles.polaroidCard(),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBhweeDqK7cfx6FGBKWhcAYPW9AkaPzgKU0rQc_AcZS4rODLP2sB9WdkWkj1yH-Y9xAAV4EXiyUDR99MubUQuqcJDOzAkH1_HmTnWg8QPEvnvVgeLjJrspwddE39R8j0n-21X1CSGuX2FWmd-TIJonqH1JVLb8hJWIRZg3cXfTbVtmWkD4vWcJG8kwTssPhkq8GvR5pxDLU6Z56Ot0N0zeMzWSOVtqCw2S0B-Fb5Sj7Saqccj3gtLTsVWASDa7_LTSWXH7SI8eMHyW7',
                            height: width < 600 ? 260 : 420,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kyoto, 2024',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: NavTripPalette.mutedInk,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  transform: Matrix4.translationValues(stickyHover ? 10.0 : 0.0, stickyHover ? -8.0 : 0.0, 0.0)
                    ..rotateZ(stickyHover ? -0.03 : -0.05),
                  child: Container(
                    width: 190,
                    height: 160,
                    padding: const EdgeInsets.all(16),
                    decoration: NavTripStyles.stickyNote(),
                    child: const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Tip: Morning walks in Higashiyama are quietest before 7 AM.',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          height: 1.15,
                          color: NavTripPalette.ink,
                        ),
                      ),
                    ),
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

class _JourneyStepsSection extends StatelessWidget {
  const _JourneyStepsSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    final steps = [
      _JourneyStepData(
        title: 'Curate Your Muse',
        body: 'Describe your dream vibe. Whether it is cobblestone cafes or neon-lit skylines, the planner listens for mood first.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDpSdAuxc6dy7lfNXuZ7twkJAlNHf9SQ0PYgmRamCAMvs5bTLczWOX-dnSBDCo6CIe7JQWYvHvtkc2w7lGCba26MyaPLUglsT4AHGRvR5R522qLI4kLwDy542D5CwxrvSZh3ySYE-h95vYT7fnIGDtJ6lddL_p0MbecpYMan-5ZrpEUwRn6Zt21GtU-lEZ6iCI4DaP48WbyGKbPnI-9uuvxynVTeSORc_IhMPvAoxSqlNu1bWmA78soPR-6BzcAduDb7uoBV3YgKsgS',
      ),
      _JourneyStepData(
        title: 'Precision Routing',
        body: 'Watch as ideas turn into a logical day plan. Logistics quietly fall into place while the timeline stays beautiful.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDRpFXG1Fa46N8fnNfSf8ICeYzNmolpXUgu4jXbP8ztVfuOIQlYaWQ6iNV-lL-GvKCz-1VceN1uB2eh1ZNZxDVL8RaP-P4-DtGfljwxFr_52MfP2aQuvwH3GXVTXStYhFHl3cgAAofRo_Pw_t7a0st6zMyVmBdIAxKaj0rrmHQxTutpbbH4Lem9BsX5FQqtUYt-QpyFJz0KicXnnpVvuYKCUktSGxKH4v9vKa2fH8nGNGjRSxAyL8C2rEbDTZLYU9irDpSphbv0vLyX',
      ),
      _JourneyStepData(
        title: 'Heirloom Export',
        body: 'Download a printable journal or keep the trip on your devices. The route feels permanent, not disposable.',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCriTJzsnotX5klGQPPsz_A2QTNUE-wnECnaAfcOFxBJYj4iJKEP73q6G7u_LaXEEW57asETqmQcGVE4uyLDziTXVn_7NyI3ndJNnMQbGbE36vlEgO5Tw7HXEzJI1nlbMpy2k3GeHRnEBI0C6E_wAzy5iTsqxsoKAv05n65PZ41l_n4Lk02C251yayulk-iRFDqVGPix9YrZW4kFxTXKK1QB0fmdWo8w-shbBRCpBPlXlTSRxJ7lhZQaOVog03jQ5ottDZ7rD6oXADh',
      ),
    ];

    return Column(
      children: [
        const SectionHeading(
          title: 'Your Journey in 3 Steps',
          alignment: CrossAxisAlignment.center,
        ),
        const SizedBox(height: 44),
        if (isDesktop)
          Stack(
            children: [
              Positioned(
                left: 28,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: NavTripPalette.terracotta),
              ),
              Column(
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    _JourneyStepTile(data: steps[i], reversed: i.isOdd),
                    if (i != steps.length - 1) const SizedBox(height: 30),
                  ],
                ],
              ),
            ],
          )
        else
          Column(
            children: [
              for (final step in steps) ...[
                _JourneyStepTile(data: step, reversed: false),
                const SizedBox(height: 24),
              ],
            ],
          ),
      ],
    );
  }
}

class _JourneyStepData {
  const _JourneyStepData({
    required this.title,
    required this.body,
    required this.image,
  });

  final String title;
  final String body;
  final String image;
}

class _JourneyStepTile extends StatelessWidget {
  const _JourneyStepTile({
    required this.data,
    required this.reversed,
  });

  final _JourneyStepData data;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final card = Container(
      width: width < 900 ? double.infinity : 460,
      padding: const EdgeInsets.all(14),
      decoration: NavTripStyles.paperCard(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: NavTripPalette.terracottaDeep)),
          const SizedBox(height: 8),
          Text(data.body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: NavTripPalette.mutedInk)),
          const SizedBox(height: 14),
          Transform.rotate(
            angle: reversed ? 0.03 : -0.03,
            child: Container(
              decoration: NavTripStyles.polaroidCard(),
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.network(data.image, height: 220, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            ),
          ),
        ],
      ),
    );

    if (width < 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: NavTripPalette.terracotta, width: 3),
                  ),
                ),
                const SizedBox(height: 8),
                Container(width: 2, height: 300, color: NavTripPalette.terracotta),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(child: card),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: reversed ? 120 : 48, right: reversed ? 48 : 120),
      child: Row(
        mainAxisAlignment: reversed ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!reversed) ...[
            _TimelineDot(),
            const SizedBox(width: 20),
            card,
          ] else ...[
            card,
            const SizedBox(width: 20),
            _TimelineDot(),
          ],
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: NavTripPalette.terracotta, width: 3),
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
        Text('Inspired Destinations', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: NavTripPalette.terracottaDeep, fontSize: width < 600 ? 36 : 48)),
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
                child: Image.network(widget.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
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
                    Text(widget.country, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(widget.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffdec0b7), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NavTrip-AI', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: NavTripPalette.terracottaDeep)),
              const SizedBox(height: 6),
              Text('A travel planner shaped like a story.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: NavTripPalette.mutedInk)),
            ],
          ),
          TextButton(onPressed: onExplore, child: const Text('Jump to steps')),
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
            _NavItem(label: 'Explore', icon: Icons.explore, onTap: () => Navigator.of(context).pushNamed('/dashboard')),
            _FabItem(onTap: () => Navigator.of(context).pushNamed('/dashboard')),
            _NavItem(label: 'Trips', icon: Icons.map, onTap: () => Navigator.of(context).pushNamed('/trip-details')),
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



