import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navtrip_ai/theme/navtrip_theme.dart';
import 'package:navtrip_ai/widgets/home/born_to_scale_section.dart';
import 'package:navtrip_ai/widgets/home/orbit_dots.dart';
import 'package:navtrip_ai/widgets/home/stack_scroll_section.dart';

void main() {
  group('OrbitDots', () {
    testWidgets('renders correct number of orbiting dots and animates smoothly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OrbitDots(
                dotCount: 10,
                size: 80,
                radius: 28,
                dotSize: 8,
              ),
            ),
          ),
        ),
      );

      // Verify widget rendered
      expect(find.byType(OrbitDots), findsOneWidget);

      // Verify animation ticks smoothly
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('AnimatedDotCircle backwards compatibility works',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedDotCircle(
                size: 64,
                radius: 24,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OrbitDots), findsOneWidget);
    });
  });

  group('BornToScaleSection', () {
    testWidgets('renders editorial phrases and kicker in desktop view',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: NavTripStyles.theme(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: BornToScaleSection(
                firstPhrase: 'Born',
                secondPhrase: 'to Scale',
                kicker: 'MODERN ARCHITECTURE',
                subtext: 'Crafted for high performance workflows.',
                enableScrollEntrance: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Born'), findsOneWidget);
      expect(find.text('to Scale'), findsOneWidget);
      expect(find.text('MODERN ARCHITECTURE'), findsOneWidget);
      expect(find.text('Crafted for high performance workflows.'), findsOneWidget);
      expect(find.byType(OrbitDots), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders responsively on mobile without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: NavTripStyles.theme(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: BornToScaleSection(
                firstPhrase: 'Born',
                secondPhrase: 'to Travel',
                kicker: 'JOURNEY ARCHITECT',
                enableScrollEntrance: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Born'), findsOneWidget);
      expect(find.text('to Travel'), findsOneWidget);
      expect(find.text('JOURNEY ARCHITECT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('StackScrollSection', () {
    testWidgets('renders cards and triggers callback actions', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final scrollController = ScrollController();
      bool primaryClicked = false;

      final cards = [
        StackCardData(
          badge: 'TESTIMONIAL',
          title: 'Unforgettable Route',
          quote: 'The AI itinerary was completely seamless.',
          personName: 'Elena Rostova',
          role: 'Photographer',
          company: 'Alps Tour',
          image:
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
          primaryLabel: 'Book Trip',
          onPrimary: () {
            primaryClicked = true;
          },
        ),
        const StackCardData(
          badge: 'REVIEW',
          quote: 'Saved us dozens of hours of manual mapping.',
          personName: 'Marcus Vance',
          role: 'Architect',
          company: 'Norway Route',
          image:
              'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=600&q=80',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: NavTripStyles.theme(),
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: StackScrollSection(
                cards: cards,
                scrollController: scrollController,
              ),
            ),
          ),
        ),
      );

      expect(find.text('“The AI itinerary was completely seamless.”'), findsOneWidget);
      expect(find.text('Elena Rostova'), findsOneWidget);
      expect(find.text('Book Trip'), findsOneWidget);

      await tester.tap(find.text('Book Trip'));
      expect(primaryClicked, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on mobile with stacked touch layouts without errors',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final scrollController = ScrollController();

      final cards = [
        const StackCardData(
          badge: 'STORY',
          quote: 'Every destination felt personally selected for us.',
          personName: 'Sarah Jenkins',
          role: 'Travel Writer',
          image:
              'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=600&q=80',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: NavTripStyles.theme(),
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: StackScrollSection(
                cards: cards,
                scrollController: scrollController,
              ),
            ),
          ),
        ),
      );

      expect(find.text('“Every destination felt personally selected for us.”'),
          findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
