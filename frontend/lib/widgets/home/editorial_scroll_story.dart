import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';
import 'born_to_explore_gap.dart';

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
  final ValueNotifier<double> _progress = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_syncProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncProgress());
  }

  @override
  void didUpdateWidget(covariant EditorialScrollStory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_syncProgress);
      widget.scrollController.addListener(_syncProgress);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_syncProgress);
    _progress.dispose();
    super.dispose();
  }

  void _syncProgress() {
    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final viewport = MediaQuery.maybeSizeOf(context)?.height ?? 800;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final travel = math.max(1.0, renderObject.size.height - viewport);
    _progress.value = (-top / travel).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 760;

    if (mobile) {
      return Container(
        key: _key,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            SizedBox(
              height: math.max(620, MediaQuery.sizeOf(context).height * 0.86),
              child: _EditorialHero(
                progress: 0,
                mobile: true,
                onPrimary: widget.onPrimary,
                onExplore: widget.onExplore,
              ),
            ),
            _ComparisonPanels(mobile: true),
            _PlannerDemo(mobile: true),
            _ProofStack(mobile: true),
            _TalksLikePeople(onPrimary: widget.onPrimary),
          ],
        ),
      );
    }

    final viewport = MediaQuery.sizeOf(context).height;
    return SizedBox(
      key: _key,
      height: viewport * 3.15,
      child: ValueListenableBuilder<double>(
        valueListenable: _progress,
        builder: (context, progress, child) {
          final heroOut = _interval(progress, 0.0, 0.28);
          final panelsIn = _interval(progress, 0.18, 0.43);
          final demoIn = _interval(progress, 0.38, 0.63);
          final proofIn = _interval(progress, 0.58, 0.82);
          final finalIn = _interval(progress, 0.78, 1.0);

          return Stack(
            children: [
              Positioned(
                top: widget.scrollController.hasClients
                    ? widget.scrollController.offset.clamp(0.0, viewport * 2.15)
                    : 0,
                left: 0,
                right: 0,
                height: viewport,
                child: ClipRect(
                  child: Stack(
                    children: [
                      _StageLayer(
                        opacity: 1 - panelsIn,
                        y: -80 * heroOut,
                        child: _EditorialHero(
                          progress: heroOut,
                          mobile: false,
                          onPrimary: widget.onPrimary,
                          onExplore: widget.onExplore,
                        ),
                      ),
                      _StageLayer(
                        opacity: panelsIn * (1 - demoIn),
                        y: 90 * (1 - panelsIn) - 40 * demoIn,
                        child: const _ComparisonPanels(mobile: false),
                      ),
                      _StageLayer(
                        opacity: demoIn * (1 - proofIn),
                        y: 90 * (1 - demoIn) - 40 * proofIn,
                        child: const _PlannerDemo(mobile: false),
                      ),
                      _StageLayer(
                        opacity: proofIn * (1 - finalIn),
                        y: 90 * (1 - proofIn) - 40 * finalIn,
                        child: const _ProofStack(mobile: false),
                      ),
                      _StageLayer(
                        opacity: finalIn,
                        y: 120 * (1 - finalIn),
                        child: _TalksLikePeople(onPrimary: widget.onPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _interval(double value, double start, double end) {
    final t = ((value - start) / (end - start)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }
}

class _StageLayer extends StatelessWidget {
  const _StageLayer({
    required this.child,
    required this.opacity,
    required this.y,
  });

  final Widget child;
  final double opacity;
  final double y;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: opacity < 0.5,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, y),
          child: child,
        ),
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
        mobile ? 54 : 42,
        mobile ? 20 : 72,
        mobile ? 44 : 52,
      ),
      child: Column(
        children: [
          if (!mobile) const _LogoStrip(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gap = mobile ? 12.0 : 34.0;
                final sideWidth = math.max(
                  88.0,
                  (constraints.maxWidth - ringSize - gap * 2) / 2,
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(-72 * progress, 0),
                      child: _HeroWordSlot(
                        width: sideWidth,
                        alignment: Alignment.centerLeft,
                        text: 'Born',
                        size: heroSize,
                      ),
                    ),
                    SizedBox(width: gap),
                    Transform.scale(
                      scale: ringScale,
                      child: AnimatedDotCircle(
                        dotColor: NavTripEditorial.navy,
                        size: ringSize,
                        radius: mobile ? 26 : 37,
                        dotWidth: mobile ? 10 : 15,
                        dotHeight: mobile ? 18 : 28,
                      ),
                    ),
                    SizedBox(width: gap),
                    Transform.translate(
                      offset: Offset(72 * progress, 0),
                      child: _HeroWordSlot(
                        width: sideWidth,
                        alignment: Alignment.centerRight,
                        text: 'to Travel.',
                        size: heroSize,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _IntroFooter(onPrimary: onPrimary, onExplore: onExplore),
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

class _ComparisonPanels extends StatelessWidget {
  const _ComparisonPanels({required this.mobile});

  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 20 : 72,
        vertical: mobile ? 52 : 90,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: _EditorialWord('Why plan with AI?',
                      size: mobile ? 42 : 58)),
              if (!mobile)
                const SizedBox(
                  width: 380,
                  child: _EditorialBody(
                    'Compare the old itinerary grind with a route engine that keeps context in motion.',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 58),
          LayoutBuilder(
            builder: (context, constraints) {
              final panelWidth = mobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 18 * 2) / 3;
              final cards = [
                const _SolutionPanel(
                  label: 'Manual Search',
                  title: 'Tabs, maps, notes',
                  body:
                      'Decisions spread across bookmarks, blogs, and tired spreadsheets.',
                  dark: false,
                ),
                const _SolutionPanel(
                  label: 'Generic Trips',
                  title: 'Pretty, not personal',
                  body:
                      'Static templates ignore pace, travel time, and what you care about.',
                  dark: false,
                ),
                const _SolutionPanel(
                  label: 'Our Solution',
                  title: 'NavTrip AI',
                  body:
                      'Humanlike trip planning with daily route logic, budgets, and editable stops.',
                  dark: true,
                ),
              ];

              if (mobile) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      SizedBox(width: panelWidth, child: card),
                      const SizedBox(height: 14),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    SizedBox(width: panelWidth, child: cards[i]),
                    if (i != cards.length - 1) const SizedBox(width: 18),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SolutionPanel extends StatelessWidget {
  const _SolutionPanel({
    required this.label,
    required this.title,
    required this.body,
    required this.dark,
  });

  final String label;
  final String title;
  final String body;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : NavTripEditorial.navy;
    return Container(
      height: 440,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? NavTripEditorial.navy : NavTripEditorial.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BlueKicker(label,
              color: dark ? Colors.white : NavTripEditorial.blue),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: fg,
                  fontSize: 34,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 24),
          _CheckLine(text: body, dark: dark),
          const SizedBox(height: 18),
          _CheckLine(
            text: dark
                ? 'Handles complex, multi-stop routes'
                : 'Needs constant re-checking',
            dark: dark,
          ),
        ],
      ),
    );
  }
}

class _PlannerDemo extends StatelessWidget {
  const _PlannerDemo({required this.mobile});

  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 20 : 72,
        vertical: mobile ? 54 : 78,
      ),
      child: mobile
          ? const Column(
              children: [
                _DemoOrb(),
                SizedBox(height: 24),
                _DemoForm(),
              ],
            )
          : const Row(
              children: [
                Expanded(child: _DemoOrb()),
                SizedBox(width: 24),
                Expanded(child: _DemoForm()),
              ],
            ),
    );
  }
}

class _DemoOrb extends StatelessWidget {
  const _DemoOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NavTripEditorial.panel),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 290,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(
                colors: [
                  Color(0xff4ed5d8),
                  Color(0xff356de9),
                  Color(0xffb89af7),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22356de9),
                  blurRadius: 36,
                  offset: Offset(0, 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _UseChip('Hidden Gems'),
              _UseChip('Food Walk'),
              _UseChip('Budget Route'),
              _UseChip('Family Trip'),
              _UseChip('Slow Travel'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoForm extends StatelessWidget {
  const _DemoForm();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NavTripEditorial.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BlueKicker('Trip Brief'),
          const SizedBox(height: 26),
          const _FieldLine(label: 'Destination', value: 'Jaipur, Rajasthan'),
          const _FieldLine(label: 'Dates', value: '4 days in October'),
          const _FieldLine(
              label: 'Mood', value: 'History, food, quiet mornings'),
          const Spacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                disabledBackgroundColor: NavTripEditorial.navy,
                disabledForegroundColor: Colors.white,
              ),
              child: const Text('Generate plan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofStack extends StatelessWidget {
  const _ProofStack({required this.mobile});

  final bool mobile;

  static const _cards = [
    _ProofData(
      quote:
          'NavTrip turned our scattered wishlist into days that finally made sense.',
      name: 'Maya Rao',
      role: 'Weekend explorer',
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDRpFXG1Fa46N8fnNfSf8ICeYzNmolpXUgu4jXbP8ztVfuOIQlYaWQ6iNV-lL-GvKCz-1VceN1uB2eh1ZNZxDVL8RaP-P4-DtGfljwxFr_52MfP2aQuvwH3GXVTXStYhFHl3cgAAofRo_Pw_t7a0st6zMyVmBdIAxKaj0rrmHQxTutpbbH4Lem9BsX5FQqtUYt-QpyFJz0KicXnnpVvuYKCUktSGxKH4v9vKa2fH8nGNGjRSxAyL8C2rEbDTZLYU9irDpSphbv0vLyX',
      color: NavTripEditorial.panel,
      foreground: NavTripEditorial.navy,
    ),
    _ProofData(
      quote:
          'It balanced iconic places with the little pauses that make a trip feel personal.',
      name: 'Arjun Mehta',
      role: 'Family trip planner',
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBhweeDqK7cfx6FGBKWhcAYPW9AkaPzgKU0rQc_AcZS4rODLP2sB9WdkWkj1yH-Y9xAAV4EXiyUDR99MubUQuqcJDOzAkH1_HmTnWg8QPEvnvVgeLjJrspwddE39R8j0n-21X1CSGuX2FWmd-TIJonqH1JVLb8hJWIRZg3cXfTbVtmWkD4vWcJG8kwTssPhkq8GvR5pxDLU6Z56Ot0N0zeMzWSOVtqCw2S0B-Fb5Sj7Saqccj3gtLTsVWASDa7_LTSWXH7SI8eMHyW7',
      color: NavTripEditorial.navy,
      foreground: Colors.white,
    ),
    _ProofData(
      quote: 'By cleaning up the route, we saved hours and kept the day calm.',
      name: 'Leah Santos',
      role: 'Solo traveler',
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBAEXGXMZdRt9Qlfp1YXjUFUchOD7q0aHNBBCnRvcAuYkdoUCzeWjgKfpUH7_WtpKIWq8dvG1VM5W_O52FR9Q0g_nolife3sRwuNnYoQRQiWYbk44GMKwEFh7U5ffGv5BnnFAYd231PWxXpGqFkFpGzNFjwMETzYQY6ShT1bWqgxy6scPIwpMCC4cFQO_jCS1pM9Dg-odeFFuyLcfPcgI6Gn_q6_Ba9kXVl6jYoM4tdLLLQRsQqRhfEPOZANbTG5QVgKI1R7IRuu8JI',
      color: NavTripEditorial.blue,
      foreground: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 20 : 72,
        vertical: mobile ? 52 : 56,
      ),
      child: mobile
          ? Column(
              children: [
                for (final card in _cards) _ProofCard(data: card),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      for (var i = 0; i < _cards.length; i++)
                        Expanded(
                          child: Transform.translate(
                            offset: Offset(0, i * -10.0),
                            child: _ProofCard(
                              data: _cards[i],
                              compact: true,
                              margin: EdgeInsets.only(
                                bottom: i == _cards.length - 1 ? 0 : 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _ProofData {
  const _ProofData({
    required this.quote,
    required this.name,
    required this.role,
    required this.image,
    required this.color,
    required this.foreground,
  });

  final String quote;
  final String name;
  final String role;
  final String image;
  final Color color;
  final Color foreground;
}

class _ProofCard extends StatelessWidget {
  const _ProofCard({
    required this.data,
    this.compact = false,
    this.margin = const EdgeInsets.only(bottom: 18),
  });

  final _ProofData data;
  final bool compact;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 760;
    final compactDesktop = compact && !mobile;
    return Container(
      constraints: const BoxConstraints(maxWidth: 1080),
      margin: margin,
      padding: EdgeInsets.all(mobile ? 18 : (compactDesktop ? 18 : 28)),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _proofChildren(context, mobile),
            )
          : Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _proofChildren(context, mobile, compactDesktop),
                  ),
                ),
                SizedBox(width: compactDesktop ? 20 : 34),
                if (compactDesktop)
                  SizedBox(
                    width: 112,
                    height: 136,
                    child: _ProofImage(data: data),
                  )
                else
                  Expanded(
                    flex: 3,
                    child: _ProofImage(data: data),
                  ),
              ],
            ),
    );
  }

  List<Widget> _proofChildren(
    BuildContext context,
    bool mobile, [
    bool compact = false,
  ]) {
    return [
      Text(
        '"',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: data.foreground,
              fontSize: mobile ? 32 : (compact ? 24 : 46),
              letterSpacing: 0,
            ),
      ),
      Text(
        data.quote,
        maxLines: compact ? 2 : null,
        overflow: compact ? TextOverflow.ellipsis : TextOverflow.visible,
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: data.foreground,
              fontSize: mobile ? 34 : (compact ? 28 : 54),
              height: compact ? 1.08 : 1.04,
              letterSpacing: 0,
            ),
      ),
      SizedBox(height: mobile ? 28 : (compact ? 14 : 56)),
      Row(
        children: [
          if (mobile) ...[
            SizedBox(width: 92, height: 92, child: _ProofImage(data: data)),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: data.foreground,
                        letterSpacing: 0,
                      ),
                ),
                Text(
                  data.role,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: data.foreground.withValues(alpha: 0.72),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }
}

class _ProofImage extends StatelessWidget {
  const _ProofImage({required this.data});

  final _ProofData data;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 0.74,
        child: Image.network(
          data.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _ImageFallback(),
        ),
      ),
    );
  }
}

class _TalksLikePeople extends StatelessWidget {
  const _TalksLikePeople({required this.onPrimary});

  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 760;
    final wordSize = mobile ? 58.0 : 100.0;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 20 : 72,
        vertical: mobile ? 80 : 120,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: mobile ? 22 : 72,
              runSpacing: 18,
              children: [
                _EditorialWord('Plans', size: wordSize),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDpSdAuxc6dy7lfNXuZ7twkJAlNHf9SQ0PYgmRamCAMvs5bTLczWOX-dnSBDCo6CIe7JQWYvHvtkc2w7lGCba26MyaPLUglsT4AHGRvR5R522qLI4kLwDy542D5CwxrvSZh3ySYE-h95vYT7fnIGDtJ6lddL_p0MbecpYMan-5ZrpEUwRn6Zt21GtU-lEZ6iCI4DaP48WbyGKbPnI-9uuvxynVTeSORc_IhMPvAoxSqlNu1bWmA78soPR-6BzcAduDb7uoBV3YgKsgS',
                    width: mobile ? 96 : 140,
                    height: mobile ? 150 : 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ImageFallback(),
                  ),
                ),
                _EditorialWord('Like', size: wordSize),
              ],
            ),
            _EditorialWord('People', size: wordSize),
            const SizedBox(height: 34),
            FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: NavTripEditorial.navy,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              ),
              child: const Text('Plan your trip'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NavTripEditorial.panel,
      alignment: Alignment.center,
      child: const Icon(
        Icons.landscape_outlined,
        color: NavTripEditorial.blue,
      ),
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
  const _BlueKicker(this.text, {this.color = NavTripEditorial.blue});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontSize: 13,
            letterSpacing: 0,
          ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({
    required this.text,
    required this.dark,
  });

  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dark ? '✓' : '×',
          style: TextStyle(
            color: dark ? Colors.white : NavTripEditorial.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.82)
                      : NavTripEditorial.navy.withValues(alpha: 0.74),
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}

class _UseChip extends StatelessWidget {
  const _UseChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: NavTripEditorial.panel,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: NavTripEditorial.navy,
              letterSpacing: 0,
            ),
      ),
    );
  }
}

class _FieldLine extends StatelessWidget {
  const _FieldLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BlueKicker(label),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: NavTripEditorial.navy,
                  fontSize: 25,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xffc7cad6)),
        ],
      ),
    );
  }
}
