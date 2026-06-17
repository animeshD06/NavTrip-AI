import 'package:flutter_test/flutter_test.dart';
import 'package:navtrip_ai/main.dart';

void main() {
  testWidgets('shows planner home screen', (tester) async {
    await tester.pumpWidget(const NavTripApp(loadPlacesOnStart: false));

    expect(find.text('NavTrip AI'), findsOneWidget);
    expect(find.text('Search places'), findsOneWidget);
    expect(find.text('Generate itinerary'), findsOneWidget);
    expect(find.text('Open tourist map'), findsOneWidget);
  });
}
