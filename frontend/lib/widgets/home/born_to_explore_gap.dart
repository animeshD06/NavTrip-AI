import 'package:flutter/material.dart';

import '../../theme/navtrip_theme.dart';
import 'born_to_scale_section.dart';

export 'born_to_scale_section.dart';
export 'orbit_dots.dart';

/// Legacy wrapper for BornToScaleSection / BornToTravelSection.
class BornToExploreGap extends StatelessWidget {
  const BornToExploreGap({
    this.scrollController,
    super.key,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return BornToScaleSection(
      firstPhrase: 'Born',
      secondPhrase: 'to Explore',
      kicker: null,
      scrollController: scrollController,
      textColor: NavTripPalette.terracottaDeep,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 72.0),
    );
  }
}
