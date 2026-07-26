import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navtrip_ai/models/app_user.dart';
import 'package:navtrip_ai/models/tourist_place.dart';
import 'package:navtrip_ai/providers/auth_provider.dart';
import 'package:navtrip_ai/providers/trip_planner_controller.dart';
import 'package:navtrip_ai/screens/dashboard_screen.dart';
import 'package:navtrip_ai/screens/home_screen.dart';
import 'package:navtrip_ai/services/api_client.dart';
import 'package:navtrip_ai/theme/navtrip_theme.dart';
import 'package:navtrip_ai/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

void main() {
  final originalFlutterError = FlutterError.onError;

  setUpAll(() {
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('NetworkImageLoadException')) {
        return;
      }
      originalFlutterError?.call(details);
    };
  });

  tearDownAll(() {
    FlutterError.onError = originalFlutterError;
  });

  testWidgets('shows the current home screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NavTripStyles.theme(),
        home: const HomeScreen(loadPlacesOnStart: false),
      ),
    );

    expect(find.text('NavTrip-AI'), findsWidgets);
    expect(find.text('Start Planning'), findsAtLeastNWidgets(1));
    expect(find.text('How it works'), findsOneWidget);
    expect(find.text('AI TRIP PLANNING'), findsOneWidget);
    expect(find.text('BUDGET OPTIMIZATION'), findsOneWidget);
    expect(find.text('Enter Destination'), findsOneWidget);
    expect(find.text('Ready to Travel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile bottom nav boots without layout exceptions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: NavTripStyles.theme(),
        home: const HomeScreen(loadPlacesOnStart: false),
      ),
    );

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard stack boots with quotes and actions', (tester) async {
    _setDesktopView(tester);

    await tester.pumpWidget(_dashboardApp(
      auth: FakeAuthProvider.authenticated(),
    ));
    await tester.pump();

    expect(find.textContaining('Welcome Back'), findsOneWidget);
    expect(find.text('TODAY\'S SPOTLIGHT'), findsOneWidget);
    expect(find.text('View Itinerary'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Not all those who wander are lost'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Sign In page opens', (tester) async {
    _setDesktopView(tester);

    await tester.pumpWidget(_routedAuthApp(
      auth: FakeAuthProvider.unauthenticated(),
      initialRoute: '/login',
    ));

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
  });

  testWidgets('Planner route opens dashboard when authenticated',
      (tester) async {
    _setDesktopView(tester);

    await tester.pumpWidget(_routedAuthApp(
      auth: FakeAuthProvider.authenticated(),
      initialRoute: '/dashboard',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard loaded'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('Planner redirects to login when unauthenticated',
      (tester) async {
    _setDesktopView(tester);

    await tester.pumpWidget(_routedAuthApp(
      auth: FakeAuthProvider.unauthenticated(),
      initialRoute: '/',
    ));

    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('You will return to /dashboard after authentication.'),
        findsOneWidget);
  });
}

void _setDesktopView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1366, 768);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _routedAuthApp({
  required AuthProvider auth,
  required String initialRoute,
}) {
  String? redirectTarget(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is String ? arguments : null;
  }

  return ChangeNotifierProvider<AuthProvider>.value(
    value: auth,
    child: MaterialApp(
      theme: NavTripStyles.theme(),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
                child: const Text('Planner'),
              ),
            ),
        '/dashboard': (_) => const AuthGuard(
              protectedRoute: '/dashboard',
              child: Text('Dashboard loaded'),
            ),
        '/login': (context) {
          final redirectTo = redirectTarget(context);
          return Scaffold(
            body: Column(
              children: [
                const Text('Sign in'),
                const Text('Email address'),
                if (redirectTo != null)
                  Text('You will return to $redirectTo after authentication.'),
              ],
            ),
          );
        },
      },
    ),
  );
}

Widget _dashboardApp({required AuthProvider auth}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      Provider<ApiClient>(create: (_) => FakeApiClient()),
      ChangeNotifierProxyProvider<ApiClient, TripPlannerController>(
        create: (context) => TripPlannerController(context.read<ApiClient>()),
        update: (_, apiClient, controller) {
          return controller ?? TripPlannerController(apiClient);
        },
      ),
    ],
    child: MaterialApp(
      theme: NavTripStyles.theme(),
      routes: {
        '/dashboard': (_) => const DashboardScreen(),
        '/trip-details': (_) => const Scaffold(body: Text('Trip details')),
        '/trip-map': (_) => const Scaffold(body: Text('Trip map')),
        '/login': (_) => const Scaffold(body: Text('Sign in')),
      },
      initialRoute: '/dashboard',
    ),
  );
}

class FakeApiClient extends ApiClient {
  @override
  Future<Map<String, dynamic>> fetchHealth() async {
    return {'status': 'ok'};
  }

  @override
  Future<List<TouristPlace>> fetchPlaces({
    String? city,
    String? category,
    String? search,
  }) async {
    return const [];
  }
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  FakeAuthProvider._({required this.currentUser});

  factory FakeAuthProvider.authenticated() {
    return FakeAuthProvider._(
      currentUser: const AppUser(
        id: 'test-user',
        email: 'test@example.com',
        username: 'Test User',
        emailVerified: true,
      ),
    );
  }

  factory FakeAuthProvider.unauthenticated() {
    return FakeAuthProvider._(currentUser: null);
  }

  @override
  final AppUser? currentUser;

  @override
  String? get errorMessage => null;

  @override
  bool get isAuthenticated => currentUser != null;

  @override
  bool get isBusy => false;

  @override
  bool get isReady => true;

  @override
  bool get needsVerification => currentUser?.emailVerified == false;

  @override
  String? get verificationMessage =>
      needsVerification ? 'Check your email to verify your account.' : null;

  @override
  void clearMessages() {}

  @override
  Future<void> handleDeepLink(Uri uri) async {}

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {}
}
