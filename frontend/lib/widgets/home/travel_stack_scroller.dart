import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';

class TravelStackCardData {
  const TravelStackCardData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.quote,
    this.badge,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String image;
  final String quote;
  final String? badge;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? trailing;
}

class TravelStackScroller extends StatefulWidget {
  const TravelStackScroller({
    required this.cards,
    required this.scrollController,
    this.mobileBreakpoint = 900,
    this.desktopHeightFactor = 1.25,
    super.key,
  });

  final List<TravelStackCardData> cards;
  final ScrollController scrollController;
  final double mobileBreakpoint;
  final double desktopHeightFactor;

  @override
  State<TravelStackScroller> createState() => _TravelStackScrollerState();
}

class _TravelStackScrollerState extends State<TravelStackScroller> {
  final _sectionKey = GlobalKey();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant TravelStackScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_handleScroll);
      widget.scrollController.addListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted) return;
    final renderObject = _sectionKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final top = renderObject.localToGlobal(Offset.zero).dy;
      _scrollOffsetNotifier.value = -top;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (width < widget.mobileBreakpoint) {
      return Column(
        key: _sectionKey,
        children: [
          for (var i = 0; i < widget.cards.length; i++) ...[
            _StackCard(
              data: widget.cards[i],
              compact: true,
              active: true,
              progress: 0,
              reduceMotion: reduceMotion,
            ),
            if (i != widget.cards.length - 1) const SizedBox(height: 18),
          ],
        ],
      );
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    
    final itemDistance = 380.0;
    final itemStackDistance = 30.0;
    final baseScale = 0.85;
    final itemScale = 0.03;
    final rotationAmount = -0.008;
    final blurAmount = 1.0;
    
    // Position container at 5% of viewport to prevent top-clipping
    final stickyTop = viewportHeight * 0.05;

    final travel = math.max(1.0, (widget.cards.length - 1) * itemDistance);
    final sectionHeight = travel + viewportHeight * 0.65;

    return SizedBox(
      key: _sectionKey,
      height: sectionHeight,
      child: AnimatedBuilder(
        animation: _scrollOffsetNotifier,
        builder: (context, child) {
          final containerTop = -_scrollOffsetNotifier.value;
          final scrollOffset = -containerTop;
          
          final isSticking = scrollOffset >= 0.0;
          final clampedScrollOffset = scrollOffset.clamp(0.0, travel);
          final containerTopPosition = isSticking ? clampedScrollOffset : 0.0;
          
          final currentPosition = (clampedScrollOffset / itemDistance).clamp(0.0, widget.cards.length - 1.0);

          final cardHeight = math.min(680.0, math.max(560.0, viewportHeight * 0.82));

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: containerTopPosition,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: cardHeight + stickyTop + 60,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      for (var i = widget.cards.length - 1; i >= 0; i--)
                        _PositionedStackCard(
                          data: widget.cards[i],
                          index: i,
                          totalCount: widget.cards.length,
                          itemDistance: itemDistance,
                          itemStackDistance: itemStackDistance,
                          baseScale: baseScale,
                          itemScale: itemScale,
                          rotationAmount: rotationAmount,
                          blurAmount: blurAmount,
                          clampedScrollOffset: clampedScrollOffset,
                          reduceMotion: reduceMotion,
                          cardHeight: cardHeight,
                          stickyTop: stickyTop,
                        ),
                      Positioned(
                        bottom: 0,
                        child: _ProgressIndicatorDots(
                          cardCount: widget.cards.length,
                          currentPosition: currentPosition,
                        ),
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
}

class _PositionedStackCard extends StatelessWidget {
  const _PositionedStackCard({
    required this.data,
    required this.index,
    required this.totalCount,
    required this.itemDistance,
    required this.itemStackDistance,
    required this.baseScale,
    required this.itemScale,
    required this.rotationAmount,
    required this.blurAmount,
    required this.clampedScrollOffset,
    required this.reduceMotion,
    required this.cardHeight,
    required this.stickyTop,
  });

  final TravelStackCardData data;
  final int index;
  final int totalCount;
  final double itemDistance;
  final double itemStackDistance;
  final double baseScale;
  final double itemScale;
  final double rotationAmount;
  final double blurAmount;
  final double clampedScrollOffset;
  final bool reduceMotion;
  final double cardHeight;
  final double stickyTop;

  @override
  Widget build(BuildContext context) {
    final triggerStart = index * itemDistance;
    final baseOffset = stickyTop + index * itemDistance + index * itemStackDistance;

    double translateY;
    if (clampedScrollOffset < triggerStart) {
      translateY = baseOffset - clampedScrollOffset;
    } else {
      translateY = stickyTop + index * itemStackDistance;
    }

    double progress = 0.0;
    if (index < totalCount - 1 && clampedScrollOffset > triggerStart) {
      progress = ((clampedScrollOffset - triggerStart) / itemDistance).clamp(0.0, 1.0);
    }

    final targetScale = baseScale + index * itemScale;
    final scale = 1.0 - progress * (1.0 - targetScale);
    final rotation = index * rotationAmount * progress;
    final blur = progress * blurAmount;
    final opacity = (1.0 - progress * 1.15).clamp(0.0, 1.0);

    // Performance optimization: do not render completely faded out cards
    if (opacity <= 0.01) {
      return const SizedBox.shrink();
    }

    Widget cardChild = RepaintBoundary(
      child: _StackCard(
        data: data,
        compact: false,
        active: progress < 0.99,
        progress: progress,
        reduceMotion: reduceMotion,
      ),
    );

    // Performance optimization: skip Opacity wrapper if opacity is near 1
    if (opacity < 0.99) {
      cardChild = Opacity(
        opacity: opacity,
        child: cardChild,
      );
    }

    // Performance optimization: skip ImageFiltered wrapper if blur is negligible
    if (blur > 0.05 && !reduceMotion) {
      cardChild = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: cardChild,
      );
    }

    return Positioned(
      top: translateY,
      left: 0,
      right: 0,
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: cardChild,
          ),
        ),
      ),
    );
  }
}

class _StackCard extends StatelessWidget {
  const _StackCard({
    required this.data,
    required this.compact,
    required this.active,
    required this.progress,
    required this.reduceMotion,
  });

  final TravelStackCardData data;
  final bool compact;
  final bool active;
  final double progress;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = compact || width < 940;
    
    final card = SizedBox(
      width: narrow ? null : 1160,
      child: Container(
        decoration: NavTripStyles.paperCard(radius: 14).copyWith(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, active ? 0.16 : 0.09),
              blurRadius: active ? 30 : 18,
              offset: Offset(0, active ? 18 : 10),
            ),
          ],
        ),
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardCopy(data: data),
                  SizedBox(height: compact ? 12 : 18),
                  _CardImage(data: data, height: compact ? 240 : 320),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 11, child: _CardCopy(data: data, compact: true)),
                  const SizedBox(width: 26),
                  Expanded(flex: 9, child: _CardImage(data: data, height: 390)),
                ],
              ),
      ),
    );

    return Semantics(
      container: true,
      label: data.title,
      child: card,
    );
  }
}

class _CardCopy extends StatelessWidget {
  const _CardCopy({
    required this.data,
    this.compact = false,
  });

  final TravelStackCardData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (data.badge != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: NavTripPalette.terracotta,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              data.badge!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: compact ? 10 : 16),
        ],
        Text(
          data.title,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: NavTripPalette.terracottaDeep,
                fontSize: width < 600 ? 36 : (compact ? 44 : 56),
                height: 1,
              ),
        ),
        SizedBox(height: compact ? 10 : 14),
        Text(
          data.subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: NavTripPalette.mutedInk,
              ),
        ),
        SizedBox(height: compact ? 12 : 18),
        Transform.rotate(
          angle: -0.012,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: NavTripStyles.stickyNote(),
                child: Text(
                  data.quote,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: NavTripPalette.ink,
                        fontStyle: FontStyle.italic,
                        fontSize: compact ? 16 : null,
                        height: 1.28,
                      ),
                ),
              ),
              Positioned(
                top: -10,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.rotate(
                    angle: 0.03,
                    child: Container(
                      width: 90,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xddeee4d3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: const Color(0xffdec0b7).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (data.trailing != null) ...[
          SizedBox(height: compact ? 10 : 16),
          data.trailing!,
        ],
        if (data.primaryLabel != null || data.secondaryLabel != null) ...[
          SizedBox(height: compact ? 14 : 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (data.primaryLabel != null)
                FilledButton(
                  onPressed: data.onPrimary,
                  child: Text(data.primaryLabel!),
                ),
              if (data.secondaryLabel != null)
                OutlinedButton(
                  onPressed: data.onSecondary,
                  child: Text(data.secondaryLabel!),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({
    required this.data,
    required this.height,
  });

  final TravelStackCardData data;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.018,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: NavTripStyles.polaroidCard(),
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.network(
                data.image,
                height: height,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return Container(
                    height: height,
                    color: NavTripPalette.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: height,
                  color: NavTripPalette.sand,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: NavTripPalette.terracotta,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: -6,
            child: _PushPin(),
          ),
        ],
      ),
    );
  }
}

class _PushPin extends StatelessWidget {
  const _PushPin();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 2,
                height: 12,
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),
          Positioned(
            top: 8,
            child: Container(
              width: 1.5,
              height: 10,
              color: Colors.grey[400],
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 3,
                  offset: const Offset(3, 4),
                ),
              ],
              gradient: const RadialGradient(
                colors: [
                  Color(0xfffca5a5),
                  NavTripPalette.terracotta,
                  NavTripPalette.terracottaDeep,
                ],
                center: Alignment(-0.3, -0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressIndicatorDots extends StatelessWidget {
  const _ProgressIndicatorDots({
    required this.cardCount,
    required this.currentPosition,
  });

  final int cardCount;
  final double currentPosition;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(cardCount, (index) {
        final distance = (index - currentPosition).abs();
        final activeRatio = (1.0 - distance).clamp(0.0, 1.0);

        final width = 8.0 + (activeRatio * 16.0);
        final color = Color.lerp(
          NavTripPalette.outlineVariant,
          NavTripPalette.terracotta,
          activeRatio,
        ) ?? NavTripPalette.outlineVariant;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: width,
          height: 8.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: activeRatio > 0.5
                ? [
                    BoxShadow(
                      color: NavTripPalette.terracotta.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
