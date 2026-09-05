import 'package:flutter/material.dart';

import 'stack_scroll_section.dart';

export 'stack_scroll_section.dart';

/// Legacy model adapter for [StackCardData].
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

  StackCardData toStackCardData() {
    return StackCardData(
      title: title,
      quote: quote,
      personName: subtitle,
      image: image,
      badge: badge,
      primaryLabel: primaryLabel,
      onPrimary: onPrimary,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
      trailing: trailing,
    );
  }
}

/// Legacy wrapper for [StackScrollSection].
class TravelStackScroller extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return StackScrollSection(
      cards: cards.map((c) => c.toStackCardData()).toList(),
      scrollController: scrollController,
    );
  }
}
