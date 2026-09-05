import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';

/// Data model representing an individual card within [StackScrollSection].
class StackCardData {
  const StackCardData({
    required this.quote,
    required this.personName,
    required this.image,
    this.title,
    this.role,
    this.company,
    this.avatar,
    this.badge,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.backgroundColor,
    this.foregroundColor,
    this.trailing,
  });

  /// Optional card title/header above the quote.
  final String? title;

  /// Main testimonial, story, or feature quote.
  final String quote;

  /// Name of the person or customer.
  final String personName;

  /// Professional role or title.
  final String? role;

  /// Company or destination / location name.
  final String? company;

  /// URL for the customer avatar image.
  final String? avatar;

  /// High quality supporting feature image URL.
  final String image;

  /// Category badge / kicker text.
  final String? badge;

  /// Label for the primary action button.
  final String? primaryLabel;

  /// Callback for the primary action button.
  final VoidCallback? onPrimary;

  /// Label for the secondary action button.
  final String? secondaryLabel;

  /// Callback for the secondary action button.
  final VoidCallback? onSecondary;

  /// Custom background color for this card.
  final Color? backgroundColor;

  /// Custom text and icon foreground color for this card.
  final Color? foregroundColor;

  /// Optional custom trailing widget.
  final Widget? trailing;
}

/// A scroll-driven stack interaction displaying a layered deck of cards.
///
/// As the user scrolls, cards translate, scale, and transition depth smoothly.
/// Fully responsive across mobile, tablet, and desktop viewports.
class StackScrollSection extends StatefulWidget {
  const StackScrollSection({
    required this.cards,
    required this.scrollController,
    this.itemScrollDistance = 340.0,
    this.baseScale = 0.94,
    this.scaleStep = 0.02,
    this.stackOffsetStep = 14.0,
    this.cardRadius = 20.0,
    this.showProgressDots = true,
    super.key,
  }) : assert(cards.length > 0, 'cards list must not be empty');

  /// List of cards to render in the stacked sequence.
  final List<StackCardData> cards;

  /// The parent scroll controller driving the viewport.
  final ScrollController scrollController;

  /// Scroll distance required to transition between consecutive cards.
  final double itemScrollDistance;

  /// Scale applied to cards waiting behind the active card.
  final double baseScale;

  /// Incremental scale step per deck layer.
  final double scaleStep;

  /// Vertical pixel offset step per deck layer.
  final double stackOffsetStep;

  /// Corner radius for each card panel.
  final double cardRadius;

  /// Whether to display pagination progress dots under the stack.
  final bool showProgressDots;

  @override
  State<StackScrollSection> createState() => _StackScrollSectionState();
}

class _StackScrollSectionState extends State<StackScrollSection> {
  final GlobalKey _containerKey = GlobalKey();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
  }

  @override
  void didUpdateWidget(covariant StackScrollSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_handleScroll);
      widget.scrollController.addListener(_handleScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
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
    final renderObject = _containerKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final top = renderObject.localToGlobal(Offset.zero).dy;
      _scrollOffsetNotifier.value = -top;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    final itemDistance = isMobile
        ? math.min(widget.itemScrollDistance, 300.0)
        : widget.itemScrollDistance;

    // Responsive card dimensions
    final cardHeight = isMobile
        ? (viewportHeight * 0.62).clamp(440.0, 560.0)
        : (viewportHeight * 0.54).clamp(380.0, 480.0);

    final stickyTop = math.max(16.0, (viewportHeight - cardHeight) * 0.22);
    final totalTravel = math.max(1.0, (widget.cards.length - 1) * itemDistance);
    final totalSectionHeight = totalTravel + cardHeight + stickyTop + 60.0;

    return SizedBox(
      key: _containerKey,
      height: totalSectionHeight,
      child: AnimatedBuilder(
        animation: _scrollOffsetNotifier,
        builder: (context, child) {
          final scrollOffset = _scrollOffsetNotifier.value;
          final clampedOffset = scrollOffset.clamp(0.0, totalTravel);
          final pinnedTop = scrollOffset >= 0.0 ? clampedOffset : 0.0;
          final currentPosition = (clampedOffset / itemDistance)
              .clamp(0.0, widget.cards.length - 1.0);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: pinnedTop,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: cardHeight + stickyTop + 40.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Render cards in reverse order so top cards paint over background cards
                      for (var i = widget.cards.length - 1; i >= 0; i--)
                        _PositionedStackItem(
                          data: widget.cards[i],
                          index: i,
                          totalCount: widget.cards.length,
                          itemDistance: itemDistance,
                          clampedScrollOffset: clampedOffset,
                          cardHeight: cardHeight,
                          stickyTop: stickyTop,
                          baseScale: widget.baseScale,
                          scaleStep: widget.scaleStep,
                          stackOffsetStep: widget.stackOffsetStep,
                          cardRadius: widget.cardRadius,
                          isMobile: isMobile,
                        ),
                      if (widget.showProgressDots && widget.cards.length > 1)
                        Positioned(
                          bottom: 0,
                          child: _StackProgressDots(
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

class _PositionedStackItem extends StatelessWidget {
  const _PositionedStackItem({
    required this.data,
    required this.index,
    required this.totalCount,
    required this.itemDistance,
    required this.clampedScrollOffset,
    required this.cardHeight,
    required this.stickyTop,
    required this.baseScale,
    required this.scaleStep,
    required this.stackOffsetStep,
    required this.cardRadius,
    required this.isMobile,
  });

  final StackCardData data;
  final int index;
  final int totalCount;
  final double itemDistance;
  final double clampedScrollOffset;
  final double cardHeight;
  final double stickyTop;
  final double baseScale;
  final double scaleStep;
  final double stackOffsetStep;
  final double cardRadius;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final triggerStart = index * itemDistance;
    final baseOffset = stickyTop + index * stackOffsetStep;

    double translateY;
    if (clampedScrollOffset < triggerStart) {
      translateY = baseOffset + (triggerStart - clampedScrollOffset);
    } else {
      translateY = baseOffset;
    }

    double progress = 0.0;
    if (index < totalCount - 1 && clampedScrollOffset > triggerStart) {
      progress =
          ((clampedScrollOffset - triggerStart) / itemDistance).clamp(0.0, 1.0);
    }

    // Depth scale and opacity
    final targetScale = baseScale + index * scaleStep;
    final scale = (1.0 - progress * (1.0 - targetScale)).clamp(0.85, 1.05);
    final opacity = (1.0 - progress * 1.15).clamp(0.0, 1.0);

    // Performance optimization: skip invisible cards
    if (opacity <= 0.01) {
      return const SizedBox.shrink();
    }

    Widget cardWidget = RepaintBoundary(
      child: StackScrollCard(
        data: data,
        height: cardHeight,
        radius: cardRadius,
        compact: isMobile,
      ),
    );

    if (opacity < 0.99) {
      cardWidget = Opacity(
        opacity: opacity,
        child: cardWidget,
      );
    }

    return Positioned(
      top: translateY,
      left: 0,
      right: 0,
      child: Center(
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: cardWidget,
        ),
      ),
    );
  }
}

/// Standalone visual card widget for testimonial / showcase items.
class StackScrollCard extends StatelessWidget {
  const StackScrollCard({
    required this.data,
    this.height,
    this.radius = 20.0,
    this.compact = false,
    super.key,
  });

  final StackCardData data;
  final double? height;
  final double radius;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = compact || screenWidth < 840;

    final bg = data.backgroundColor ?? Colors.white;
    final fg = data.foregroundColor ?? NavTripEditorial.navy;

    return Container(
      width: isMobile ? screenWidth - 32.0 : 1040.0,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xffe8e8ea),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28.0,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 18.0 : 28.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: _CardContent(data: data, fg: fg, isMobile: true),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 7,
                  child: _CardImagePanel(
                    imageUrl: data.image,
                    radius: radius - 6,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 11,
                  child: _CardContent(data: data, fg: fg, isMobile: false),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 9,
                  child: _CardImagePanel(
                    imageUrl: data.image,
                    radius: radius - 6,
                  ),
                ),
              ],
            ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.data,
    required this.fg,
    required this.isMobile,
  });

  final StackCardData data;
  final Color fg;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: NavTripEditorial.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data.badge!.toUpperCase(),
                style: const TextStyle(
                  color: NavTripEditorial.blue,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
          ],
          if (data.title != null) ...[
            Text(
              data.title!,
              style: TextStyle(
                fontSize: isMobile ? 17.0 : 21.0,
                fontWeight: FontWeight.w600,
                color: fg.withValues(alpha: 0.85),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            '“${data.quote}”',
            maxLines: isMobile ? 3 : 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: isMobile ? 16.0 : 21.0,
              fontWeight: FontWeight.w400,
              height: 1.32,
              color: fg,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: isMobile ? 10 : 16),
          Row(
            children: [
              if (data.avatar != null && data.avatar!.isNotEmpty) ...[
                CircleAvatar(
                  radius: isMobile ? 16 : 20,
                  backgroundImage: NetworkImage(data.avatar!),
                  backgroundColor: const Color(0xffeaeaea),
                ),
                const SizedBox(width: 10),
              ] else ...[
                CircleAvatar(
                  radius: isMobile ? 16 : 20,
                  backgroundColor: NavTripEditorial.navy,
                  child: Text(
                    data.personName.isNotEmpty
                        ? data.personName[0].toUpperCase()
                        : 'T',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.personName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 14.0 : 15.5,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    if (data.role != null || data.company != null)
                      Text(
                        [data.role, data.company]
                            .whereType<String>()
                            .join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 11.5 : 13.0,
                          color: fg.withValues(alpha: 0.65),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (data.primaryLabel != null || data.secondaryLabel != null) ...[
            SizedBox(height: isMobile ? 10 : 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                if (data.primaryLabel != null)
                  FilledButton(
                    onPressed: data.onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: NavTripEditorial.navy,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 20,
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                    child: Text(data.primaryLabel!),
                  ),
                if (data.secondaryLabel != null)
                  OutlinedButton(
                    onPressed: data.onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NavTripEditorial.navy,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 18,
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                    child: Text(data.secondaryLabel!),
                  ),
              ],
            ),
          ],
          if (data.trailing != null) ...[
            const SizedBox(height: 8),
            data.trailing!,
          ],
        ],
      ),
    );
  }
}

class _CardImagePanel extends StatelessWidget {
  const _CardImagePanel({
    required this.imageUrl,
    required this.radius,
  });

  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: const Color(0xfff0f0f4),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xffe8e8ee),
              alignment: Alignment.center,
              child: const Icon(
                Icons.landscape_outlined,
                size: 42,
                color: NavTripEditorial.navy,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.25)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackProgressDots extends StatelessWidget {
  const _StackProgressDots({
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

        final width = 8.0 + (activeRatio * 18.0);
        final color = Color.lerp(
          const Color(0xffdcdce2),
          NavTripEditorial.navy,
          activeRatio,
        )!;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: width,
          height: 7.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }
}
