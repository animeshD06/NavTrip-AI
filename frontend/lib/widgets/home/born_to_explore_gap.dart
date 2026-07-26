import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';

class BornToExploreGap extends StatelessWidget {
  const BornToExploreGap({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width < 600 ? 32.0 : 48.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96.0),
      alignment: Alignment.center,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
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
  const AnimatedDotCircle({super.key});

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
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(8, (index) {
                final angle = (index * 2.0 * math.pi) / 8.0;
                final radius = 24.0;
                final x = 36.0 + radius * math.cos(angle) - 5.0;
                final y = 36.0 + radius * math.sin(angle) - 5.0;
                return Positioned(
                  left: x,
                  top: y,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: NavTripPalette.terracottaDeep,
                      shape: BoxShape.circle,
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
