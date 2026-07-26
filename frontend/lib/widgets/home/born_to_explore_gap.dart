import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';

class BornToExploreGap extends StatelessWidget {
  const BornToExploreGap({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width < 600 ? 24.0 : 36.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96.0),
      alignment: Alignment.center,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 16,
        children: [
          Text(
            'Born',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: NavTripPalette.terracottaDeep,
              fontStyle: FontStyle.italic,
            ),
          ),
          const AnimatedDotCircle(),
          Text(
            'to Explore.',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: NavTripPalette.terracottaDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedDotCircle extends StatefulWidget {
  const AnimatedDotCircle({
    this.dotColor = NavTripPalette.terracottaDeep,
    this.size = 72,
    this.radius = 24,
    this.dotWidth = 50,
    this.dotHeight = 10,
    super.key,
  });

  final Color dotColor;
  final double size;
  final double radius;
  final double dotWidth;
  final double dotHeight;

  @override
  State<AnimatedDotCircle> createState() => _AnimatedDotCircleState();
}

class _AnimatedDotCircleState extends State<AnimatedDotCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * math.pi,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(8, (index) {
                final angle = (index * 2.0 * math.pi) / 8.0;
                final center = widget.size / 2;
                final x = center +
                    widget.radius * math.cos(angle) -
                    widget.dotWidth / 2;
                final y = center +
                    widget.radius * math.sin(angle) -
                    widget.dotHeight / 2;
                return Positioned(
                  left: x,
                  top: y,
                  child: Container(
                    width: widget.dotWidth,
                    height: widget.dotHeight,
                    decoration: BoxDecoration(
                      color: widget.dotColor,
                      borderRadius: BorderRadius.circular(widget.dotWidth),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
