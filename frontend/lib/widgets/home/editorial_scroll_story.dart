import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';
import 'born_to_explore_gap.dart';
import 'stack_scroll_section.dart';

class EditorialScrollStory extends StatefulWidget {
  const EditorialScrollStory({
    required this.scrollController,
    required this.onPrimary,
    required this.onExplore,
    super.key,
  });

  final ScrollController scrollController;
  final VoidCallback onPrimary;
  final VoidCallback onExplore;

  @override
  State<EditorialScrollStory> createState() => _EditorialScrollStoryState();
}

class _EditorialScrollStoryState extends State<EditorialScrollStory> {
  final _key = GlobalKey();

  List<StackCardData> _buildStoryCards() {
    return [
      StackCardData(
        badge: 'Why plan with AI?',
        title: 'Manual Search vs Our Solution',
        quote:
            'Decisions spread across bookmarks, blogs, and tired spreadsheets. NavTrip replaces the chaos with real-time route logic, budgets, and editable stops.',
        personName: 'Manual Search vs NavTrip AI',
        role: 'What is NavTrip?',
        company: 'Handles complex, multi-stop routes',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBAEXGXMZdRt9Qlfp1YXjUFUchOD7q0aHNBBCnRvcAuYkdoUCzeWjgKfpUH7_WtpKIWq8dvG1VM5W_O52FR9Q0g_nolife3sRwuNnYoQRQiWYbk44GMKwEFh7U5ffGv5BnnFAYd231PWxXpGqFkFpGzNFjwMETzYQY6ShT1bWqgxy6scPIwpMCC4cFQO_jCS1pM9Dg-odeFFuyLcfPcgI6Gn_q6_Ba9kXVl6jYoM4tdLLLQRsQqRhfEPOZANbTG5QVgKI1R7IRuu8JI',
        primaryLabel: 'Explore Flow',
        onPrimary: widget.onExplore,
        secondaryLabel: 'Our Solution',
        onSecondary: widget.onPrimary,
      ),
      StackCardData(
        badge: 'Trip Brief & Demo',
        title: 'Smart Day Structuring',
        quote:
            'NavTrip orders stops, groups nearby places, estimates visits, and keeps the route readable from breakfast to evening.',
        personName: 'Interactive Itinerary Demo',
        role: 'Pace & Timing Logic',
        company: 'Jaipur, Amalfi & Kyoto',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCjHVtVcf5pUDBcddizpfb9nfeINpnEgWtrq-HMvA2aD9ilQLk2IsmkcNVpoR08XvpsdVQ93Zl5SEY9fqqK8VToD0RZEBQu97rr12Efx8ZdeWll2Vq24cjhYhBJDSDi_9pZf-mpsPv22b-kppUQxidiU5nagOOC6v9lpSQMTa4qO0hjEKR929OAY4m4sn-IstAgDZsEZNlA8E2lE5w_5Ca53MUkcXnfWSnQG-P6s1C1B-LJkpGCp5W88q52MSVtroABrxBuVBSNr1Ie',
        primaryLabel: 'Start Planning',
        onPrimary: widget.onPrimary,
      ),
      StackCardData(
        badge: 'Community Stories',
        title: 'Scattered Wishlists Made Calm',
        quote:
            'NavTrip turned our scattered wishlist into days that finally made sense. It balanced iconic places with the quiet pauses that make a journey memorable.',
        personName: 'Maya Rao & Arjun Mehta',
        role: 'Weekend & Family Explorers',
        company: 'NavTrip Community',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDRpFXG1Fa46N8fnNfSf8ICeYzNmolpXUgu4jXbP8ztVfuOIQlYaWQ6iNV-lL-GvKCz-1VceN1uB2eh1ZNZxDVL8RaP-P4-DtGfljwxFr_52MfP2aQuvwH3GXVTXStYhFHl3cgAAofRo_Pw_t7a0st6zMyVmBdIAxKaj0rrmHQxTutpbbH4Lem9BsX5FQqtUYt-QpyFJz0KicXnnpVvuYKCUktSGxKH4v9vKa2fH8nGNGjRSxAyL8C2rEbDTZLYU9irDpSphbv0vLyX',
        primaryLabel: 'Explore Stories',
        onPrimary: widget.onExplore,
      ),
      StackCardData(
        badge: 'Plans Like People',
        title: 'A Travel Planner Shaped Like a Story',
        quote:
            'By cleaning up routes and respecting real human energy, we saved hours and kept the journey peaceful and joyful.',
        personName: 'Plans Like People',
        role: 'Curated by Human Intuition',
        company: 'Ready to Travel',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDpSdAuxc6dy7lfNXuZ7twkJAlNHf9SQ0PYgmRamCAMvs5bTLczWOX-dnSBDCo6CIe7JQWYvHvtkc2w7lGCba26MyaPLUglsT4AHGRvR5R522qLI4kLwDy542D5CwxrvSZh3ySYE-h95vYT7fnIGDtJ6lddL_p0MbecpYMan-5ZrpEUwRn6Zt21GtU-lEZ6iCI4DaP48WbyGKbPnI-9uuvxynVTeSORc_IhMPvAoxSqlNu1bWmA78soPR-6BzcAduDb7uoBV3YgKsgS',
        primaryLabel: 'Plan your trip',
        onPrimary: widget.onPrimary,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 760;

    return Container(
      key: _key,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EditorialHero(
            progress: 0,
            mobile: mobile,
            onPrimary: widget.onPrimary,
            onExplore: widget.onExplore,
          ),
          StackScrollSection(
            cards: _buildStoryCards(),
            scrollController: widget.scrollController,
          ),
        ],
      ),
    );
  }
}

class _EditorialHero extends StatelessWidget {
  const _EditorialHero({
    required this.progress,
    required this.mobile,
    required this.onPrimary,
    required this.onExplore,
  });

  final double progress;
  final bool mobile;
  final VoidCallback onPrimary;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final heroSize = mobile ? 44.0 : (width * 0.082).clamp(72.0, 118.0);
    final ringSize = mobile ? 64.0 : 96.0;
    final ringScale = 1.0 + progress * 0.26;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        mobile ? 20 : 72,
        mobile ? 36 : 42,
        mobile ? 20 : 72,
        mobile ? 64 : 80,
      ),
      child: Column(
        children: [
          if (!mobile) ...[
            const _LogoStrip(),
            const SizedBox(height: 48),
          ],
          _IntroFooter(onPrimary: onPrimary, onExplore: onExplore),
          SizedBox(height: mobile ? 56 : 96),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = mobile ? 12.0 : 34.0;
              final sideWidth = math.max(
                88.0,
                (constraints.maxWidth - ringSize - gap * 2) / 2,
              );

              return Padding(
                padding: EdgeInsets.only(bottom: mobile ? 20.0 : 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(-72 * progress, 0),
                      child: _HeroWordSlot(
                        width: sideWidth,
                        alignment: Alignment.centerRight,
                        text: 'Born',
                        size: heroSize,
                      ),
                    ),
                    SizedBox(width: gap),
                    Transform.scale(
                      scale: ringScale,
                      child: OrbitDots(
                        dotCount: 10,
                        size: ringSize,
                        radius: mobile ? 24 : 34,
                        dotSize: mobile ? 6.5 : 8.5,
                        dotColor: NavTripEditorial.navy,
                      ),
                    ),
                    SizedBox(width: gap),
                    Transform.translate(
                      offset: Offset(72 * progress, 0),
                      child: _HeroWordSlot(
                        width: sideWidth,
                        alignment: Alignment.centerLeft,
                        text: 'to Travel.',
                        size: heroSize,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroWordSlot extends StatelessWidget {
  const _HeroWordSlot({
    required this.width,
    required this.alignment,
    required this.text,
    required this.size,
  });

  final double width;
  final Alignment alignment;
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: alignment,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: _EditorialWord(text, size: size),
        ),
      ),
    );
  }
}

class _LogoStrip extends StatelessWidget {
  const _LogoStrip();

  static const _logos = [
    'Jaipur',
    'Kyoto',
    'Marrakesh',
    'Amalfi',
    'Reykjavik',
    'Banff',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final logo in _logos)
          Text(
            logo,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: NavTripEditorial.navy.withValues(alpha: 0.72),
                  fontSize: 15,
                  letterSpacing: 0,
                ),
          ),
      ],
    );
  }
}

class _IntroFooter extends StatelessWidget {
  const _IntroFooter({
    required this.onPrimary,
    required this.onExplore,
  });

  final VoidCallback onPrimary;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 760;
    return mobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BlueKicker('Overview'),
              const SizedBox(height: 14),
              _EditorialWord('What is NavTrip?', size: 38),
              const SizedBox(height: 12),
              const _EditorialBody(
                'AI travel planning that turns mood, time, and budget into routes you can actually follow.',
              ),
              const SizedBox(height: 18),
              _HeroActions(onPrimary: onPrimary, onExplore: onExplore),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BlueKicker('Overview'),
                    const SizedBox(height: 18),
                    _EditorialWord('What is NavTrip?', size: 50),
                  ],
                ),
              ),
              SizedBox(
                width: 390,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _EditorialBody(
                      'AI based, humanlike, route-first travel planning platform',
                    ),
                    const SizedBox(height: 18),
                    _HeroActions(onPrimary: onPrimary, onExplore: onExplore),
                  ],
                ),
              ),
            ],
          );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({
    required this.onPrimary,
    required this.onExplore,
  });

  final VoidCallback onPrimary;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton(onPressed: onPrimary, child: const Text('Start Planning')),
        TextButton(onPressed: onExplore, child: const Text('See Flow')),
      ],
    );
  }
}

class _EditorialWord extends StatelessWidget {
  const _EditorialWord(this.text, {required this.size});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.visible,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: NavTripEditorial.ink,
            fontSize: size,
            fontWeight: FontWeight.w400,
            height: 0.9,
            letterSpacing: 0,
          ),
    );
  }
}

class _EditorialBody extends StatelessWidget {
  const _EditorialBody(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: NavTripEditorial.navy,
            height: 1.35,
            letterSpacing: 0,
          ),
    );
  }
}

class _BlueKicker extends StatelessWidget {
  const _BlueKicker(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: NavTripEditorial.blue,
            fontSize: 13,
            letterSpacing: 0,
          ),
    );
  }
}
