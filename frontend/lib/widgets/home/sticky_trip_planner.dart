import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';

class PlannerStepData {
  const PlannerStepData({
    required this.title,
    required this.heading,
    required this.description,
    required this.image,
    required this.icon,
    this.ctaLabel,
    this.onCta,
  });

  final String title;
  final String heading;
  final String description;
  final String image;
  final IconData icon;
  final String? ctaLabel;
  final VoidCallback? onCta;
}

class StickyTripPlanner extends StatefulWidget {
  const StickyTripPlanner({
    required this.steps,
    required this.scrollController,
    super.key,
  });

  final List<PlannerStepData> steps;
  final ScrollController scrollController;

  @override
  State<StickyTripPlanner> createState() => _StickyTripPlannerState();
}

class _StickyTripPlannerState extends State<StickyTripPlanner> {
  final _sectionKey = GlobalKey();
  late List<GlobalKey> _stepKeys;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _stepKeys = List.generate(widget.steps.length, (_) => GlobalKey());
    widget.scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateActiveStep());
  }

  @override
  void didUpdateWidget(covariant StickyTripPlanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_handleScroll);
      widget.scrollController.addListener(_handleScroll);
    }
    if (oldWidget.steps.length != widget.steps.length) {
      _stepKeys = List.generate(widget.steps.length, (_) => GlobalKey());
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    _updateActiveStep();
    if (mounted) {
      setState(() {});
    }
  }

  void _updateActiveStep() {
    var closestIndex = _activeIndex;
    var closestDistance = double.infinity;
    final viewportHeight = MediaQuery.maybeSizeOf(context)?.height ?? 800;
    final targetY = viewportHeight * 0.42;

    for (var i = 0; i < _stepKeys.length; i++) {
      final renderObject = _stepKeys[i].currentContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }

      final top = renderObject.localToGlobal(Offset.zero).dy;
      final center = top + renderObject.size.height * 0.5;
      final distance = (center - targetY).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != _activeIndex && mounted) {
      setState(() => _activeIndex = closestIndex);
    }
  }

  double _sidebarTop(BuildContext context) {
    final renderObject = _sectionKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return 0;
    }

    final sectionTop = renderObject.localToGlobal(Offset.zero).dy;
    final sectionHeight = renderObject.size.height;
    const stickyInset = 84.0;
    const panelHeight = 540.0;
    final topWithinSection = -sectionTop + stickyInset;
    return topWithinSection.clamp(
        0.0, math.max(0.0, sectionHeight - panelHeight));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 960;

    return Container(
      key: _sectionKey,
      padding: EdgeInsets.symmetric(
        horizontal: width < 600 ? 20 : 64,
        vertical: width < 600 ? 48 : 72,
      ),
      color: NavTripPalette.surfaceContainerLow,
      child: isDesktop ? _desktopLayout(context) : _mobileLayout(context),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 380),
          child: Column(
            children: [
              for (var i = 0; i < widget.steps.length; i++)
                _StepStoryPanel(
                  key: _stepKeys[i],
                  data: widget.steps[i],
                  active: i == _activeIndex,
                  index: i,
                ),
            ],
          ),
        ),
        Positioned(
          top: _sidebarTop(context),
          left: 0,
          width: 330,
          child: _StickySidebar(
            steps: widget.steps,
            activeIndex: _activeIndex,
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan a Trip',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: NavTripPalette.terracottaDeep,
                fontSize: 38,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'A guided flow from first idea to ready-to-travel itinerary.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: NavTripPalette.mutedInk,
              ),
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < widget.steps.length; i++) ...[
          _MobileStepHeader(
            title: widget.steps[i].title,
            index: i,
            completed: i < _activeIndex,
            active: i == _activeIndex,
          ),
          const SizedBox(height: 14),
          _StepStoryPanel(
            key: _stepKeys[i],
            data: widget.steps[i],
            active: true,
            index: i,
            mobile: true,
          ),
          if (i != widget.steps.length - 1) const SizedBox(height: 28),
        ],
      ],
    );
  }
}

class _StickySidebar extends StatelessWidget {
  const _StickySidebar({
    required this.steps,
    required this.activeIndex,
  });

  final List<PlannerStepData> steps;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final progress =
        steps.length <= 1 ? 0.0 : activeIndex / (steps.length - 1).toDouble();

    return Container(
      decoration: NavTripStyles.paperCard(radius: 14),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan a Trip',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: NavTripPalette.terracottaDeep,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Every step stays visible while your itinerary takes shape.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: NavTripPalette.mutedInk,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 348,
            child: Stack(
              children: [
                Positioned(
                  left: 18,
                  top: 14,
                  bottom: 14,
                  child: Container(
                    width: 2,
                    color: NavTripPalette.outlineVariant,
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 14,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    width: 2,
                    height: 320 * progress,
                    color: NavTripPalette.terracotta,
                  ),
                ),
                Column(
                  children: [
                    for (var i = 0; i < steps.length; i++) ...[
                      _TimelineStep(
                        title: steps[i].title,
                        index: i,
                        active: i == activeIndex,
                        completed: i < activeIndex,
                      ),
                      if (i != steps.length - 1) const SizedBox(height: 16),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.index,
    required this.active,
    required this.completed,
  });

  final String title;
  final int index;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      scale: active ? 1.04 : 1,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active || completed
                  ? NavTripPalette.terracotta
                  : Colors.white,
              border: Border.all(color: NavTripPalette.terracotta, width: 2),
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: active
                                ? Colors.white
                                : NavTripPalette.terracottaDeep,
                          ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: active
                        ? NavTripPalette.terracottaDeep
                        : NavTripPalette.mutedInk,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileStepHeader extends StatelessWidget {
  const _MobileStepHeader({
    required this.title,
    required this.index,
    required this.completed,
    required this.active,
  });

  final String title;
  final int index;
  final bool completed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return _TimelineStep(
      title: title,
      index: index,
      completed: completed,
      active: active,
    );
  }
}

class _StepStoryPanel extends StatelessWidget {
  const _StepStoryPanel({
    required this.data,
    required this.active,
    required this.index,
    this.mobile = false,
    super.key,
  });

  final PlannerStepData data;
  final bool active;
  final int index;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final panel = Container(
      constraints: BoxConstraints(minHeight: mobile ? 0 : 560),
      margin: EdgeInsets.only(bottom: mobile ? 0 : 34),
      padding: EdgeInsets.all(width < 600 ? 16 : 22),
      decoration: NavTripStyles.paperCard(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: NavTripPalette.terracotta,
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                'Step ${index + 1}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: NavTripPalette.terracotta,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            data.heading,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: NavTripPalette.terracottaDeep,
                  fontSize: width < 600 ? 32 : 46,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: NavTripPalette.mutedInk,
                ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              data.image,
              height: width < 600 ? 220 : 270,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: width < 600 ? 220 : 270,
                color: NavTripPalette.sand,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          if (data.ctaLabel != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: data.onCta,
              child: Text(data.ctaLabel!),
            ),
          ],
        ],
      ),
    );

    if (reduceMotion) {
      return panel;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: active ? 1 : 0.78,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        offset: active ? Offset.zero : const Offset(0, 0.035),
        child: panel,
      ),
    );
  }
}
