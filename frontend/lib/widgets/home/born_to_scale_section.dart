import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';
import 'orbit_dots.dart';

/// A large, minimalist editorial hero section with responsive typography
/// split around a central orbiting visual element.
///
/// Features a smooth viewport entrance animation and flexible configuration.
class BornToScaleSection extends StatefulWidget {
  const BornToScaleSection({
    this.firstPhrase = 'Born',
    this.secondPhrase = 'to Travel',
    this.kicker = 'EXPLORE THE UNCHARTED',
    this.subtext,
    this.orbitVisual,
    this.scrollController,
    this.textColor,
    this.kickerColor,
    this.backgroundColor = Colors.white,
    this.padding,
    this.fontFamily = 'Georgia',
    this.enableScrollEntrance = true,
    super.key,
  });

  /// The first part of the split editorial phrase (e.g. "Born").
  final String firstPhrase;

  /// The second part of the split editorial phrase (e.g. "to Travel" or "to Scale").
  final String secondPhrase;

  /// Optional top kicker or tag above the main headline.
  final String? kicker;

  /// Optional supporting editorial paragraph below the headline.
  final String? subtext;

  /// Optional custom central orbiting visual. If null, a default [OrbitDots] is used.
  final Widget? orbitVisual;

  /// Optional [ScrollController] to drive smooth entrance animations as the section scrolls into view.
  final ScrollController? scrollController;

  /// Color for the editorial headline text.
  final Color? textColor;

  /// Color for the kicker text.
  final Color? kickerColor;

  /// Background color of the section.
  final Color backgroundColor;

  /// Section padding.
  final EdgeInsetsGeometry? padding;

  /// Font family for the editorial headline.
  final String fontFamily;

  /// Whether to animate text entrance when entering the viewport.
  final bool enableScrollEntrance;

  @override
  State<BornToScaleSection> createState() => _BornToScaleSectionState();
}

class _BornToScaleSectionState extends State<BornToScaleSection>
    with SingleTickerProviderStateMixin {
  final GlobalKey _sectionKey = GlobalKey();
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _hasTriggeredEntrance = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.scrollController != null && widget.enableScrollEntrance) {
      widget.scrollController!.addListener(_checkVisibility);
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    } else {
      // Without scroll controller or entrance disabled, show immediately
      _entranceController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant BornToScaleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_checkVisibility);
      widget.scrollController?.addListener(_checkVisibility);
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_checkVisibility);
    _entranceController.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted || _hasTriggeredEntrance) return;

    final renderObject = _sectionKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final globalPos = renderObject.localToGlobal(Offset.zero);
    final viewportHeight = MediaQuery.maybeSizeOf(context)?.height ?? 800;

    // Trigger when section top enters within 85% of viewport height
    if (globalPos.dy <= viewportHeight * 0.85) {
      _hasTriggeredEntrance = true;
      _entranceController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1080;

    final resolvedTextColor = widget.textColor ?? NavTripEditorial.navy;
    final resolvedKickerColor = widget.kickerColor ?? NavTripEditorial.blue;

    final double headlineFontSize = isMobile
        ? (width * 0.11).clamp(32.0, 48.0)
        : (isTablet
            ? (width * 0.075).clamp(52.0, 72.0)
            : (width * 0.065).clamp(68.0, 104.0));

    final double ringSize = isMobile ? 54.0 : (isTablet ? 68.0 : 88.0);
    final double ringRadius = ringSize * 0.38;
    final double dotSize = isMobile ? 6.0 : (isTablet ? 7.0 : 8.5);

    final resolvedPadding = widget.padding ??
        EdgeInsets.symmetric(
          horizontal: isMobile ? 24.0 : (isTablet ? 48.0 : 72.0),
          vertical: isMobile ? 64.0 : (isTablet ? 84.0 : 110.0),
        );

    final visualWidget = widget.orbitVisual ??
        OrbitDots(
          dotCount: 10,
          size: ringSize,
          radius: ringRadius,
          dotSize: dotSize,
          dotColor: resolvedTextColor,
          rotationDuration: const Duration(seconds: 9),
        );

    Widget content = Container(
      key: _sectionKey,
      color: widget.backgroundColor,
      padding: resolvedPadding,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.kicker != null && widget.kicker!.isNotEmpty) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: resolvedKickerColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: resolvedKickerColor.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.kicker!.toUpperCase(),
                  style: TextStyle(
                    fontSize: isMobile ? 11.0 : 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: resolvedKickerColor,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 24.0 : 36.0),
            ],
            // Main Editorial Phrase Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = isMobile ? 16.0 : (isTablet ? 24.0 : 36.0);

                if (isMobile) {
                  // Mobile responsive balanced composition
                  return Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: gap,
                    runSpacing: 12.0,
                    children: [
                      Text(
                        widget.firstPhrase,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: widget.fontFamily,
                          fontSize: headlineFontSize,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -0.8,
                          height: 1.05,
                          color: resolvedTextColor,
                        ),
                      ),
                      visualWidget,
                      Text(
                        widget.secondPhrase,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: widget.fontFamily,
                          fontSize: headlineFontSize,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -0.8,
                          height: 1.05,
                          color: resolvedTextColor,
                        ),
                      ),
                    ],
                  );
                }

                // Desktop / Tablet side-by-side single line composition
                final availableTextWidth = math.max(
                  120.0,
                  (constraints.maxWidth - ringSize - gap * 2) / 2.0,
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: availableTextWidth,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.firstPhrase,
                            style: TextStyle(
                              fontFamily: widget.fontFamily,
                              fontSize: headlineFontSize,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -1.2,
                              height: 1.02,
                              color: resolvedTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    visualWidget,
                    SizedBox(width: gap),
                    SizedBox(
                      width: availableTextWidth,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.secondPhrase,
                            style: TextStyle(
                              fontFamily: widget.fontFamily,
                              fontSize: headlineFontSize,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -1.2,
                              height: 1.02,
                              color: resolvedTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (widget.subtext != null && widget.subtext!.isNotEmpty) ...[
              SizedBox(height: isMobile ? 24.0 : 36.0),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  widget.subtext!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 15.0 : 17.0,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    letterSpacing: 0.1,
                    color: resolvedTextColor.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!widget.enableScrollEntrance) {
      return content;
    }

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}

/// Backwards-compatible and semantic alias for BornToScaleSection.
typedef BornToTravelSection = BornToScaleSection;
