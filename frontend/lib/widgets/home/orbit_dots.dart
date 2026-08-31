import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';

/// An animated widget displaying circular dots orbiting continuously around an invisible center.
///
/// Designed with Flutter animation primitives for lightweight, 60 FPS smooth rotation.
class OrbitDots extends StatefulWidget {
  const OrbitDots({
    this.dotCount = 10,
    this.size = 80.0,
    this.radius = 28.0,
    this.dotSize = 7.5,
    this.dotColor = NavTripEditorial.navy,
    this.rotationDuration = const Duration(seconds: 8),
    this.clockwise = true,
    this.opacityVariance = false,
    super.key,
  }) : assert(dotCount >= 4, 'dotCount must be at least 4');

  /// Number of circular dots arranged in the orbit.
  final int dotCount;

  /// Total square diameter of the container widget.
  final double size;

  /// Radius of the orbit circle.
  final double radius;

  /// Diameter of each individual circular dot.
  final double dotSize;

  /// Color of the dots.
  final Color dotColor;

  /// Duration for one complete 360-degree rotation.
  final Duration rotationDuration;

  /// Direction of rotation.
  final bool clockwise;

  /// Whether to vary dot opacity around the ring for a subtle depth effect.
  final bool opacityVariance;

  @override
  State<OrbitDots> createState() => _OrbitDotsState();
}

class _OrbitDotsState extends State<OrbitDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant OrbitDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rotationDuration != widget.rotationDuration) {
      _controller.duration = widget.rotationDuration;
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.size / 2.0;

    final staticDots = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(widget.dotCount, (index) {
          final angle = (index * 2.0 * math.pi) / widget.dotCount;
          final x =
              center + widget.radius * math.cos(angle) - widget.dotSize / 2.0;
          final y =
              center + widget.radius * math.sin(angle) - widget.dotSize / 2.0;

          final opacity = widget.opacityVariance
              ? 0.4 + 0.6 * ((index + 1) / widget.dotCount)
              : 1.0;

          return Positioned(
            left: x,
            top: y,
            child: Container(
              width: widget.dotSize,
              height: widget.dotSize,
              decoration: BoxDecoration(
                color: widget.dotColor.withValues(alpha: opacity),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.dotColor.withValues(alpha: 0.18),
                    blurRadius: 3.0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final rotationValue =
              widget.clockwise ? _controller.value : (1.0 - _controller.value);
          final currentAngle = rotationValue * 2.0 * math.pi;

          return Transform.rotate(
            angle: currentAngle,
            child: child,
          );
        },
        child: staticDots,
      ),
    );
  }
}

/// Backwards-compatible alias for existing implementations.
class AnimatedDotCircle extends StatelessWidget {
  const AnimatedDotCircle({
    this.dotColor = NavTripPalette.terracottaDeep,
    this.size = 72,
    this.radius = 24,
    this.dotWidth = 8,
    this.dotHeight = 8,
    super.key,
  });

  final Color dotColor;
  final double size;
  final double radius;
  final double dotWidth;
  final double dotHeight;

  @override
  Widget build(BuildContext context) {
    return OrbitDots(
      dotCount: 10,
      size: size,
      radius: radius,
      dotSize: math.min(dotWidth, dotHeight),
      dotColor: dotColor,
    );
  }
}
