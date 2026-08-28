import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'package:navtrip_ai/config/firebase_config.dart';
import 'package:navtrip_ai/providers/auth_provider.dart';
import 'package:navtrip_ai/providers/trip_planner_controller.dart';
import 'package:navtrip_ai/screens/dashboard_screen.dart';
import 'package:navtrip_ai/screens/home_screen.dart';
import 'package:navtrip_ai/screens/login_screen.dart';
import 'package:navtrip_ai/screens/signup_screen.dart';
import 'package:navtrip_ai/screens/tourist_map_screen.dart';
import 'package:navtrip_ai/services/api_client.dart';
import 'package:navtrip_ai/theme/navtrip_theme.dart';
import 'package:navtrip_ai/widgets/auth_guard.dart';

void main() {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NavTripApp());
}

class NavTripApp extends StatefulWidget {
  const NavTripApp({
    this.loadPlacesOnStart = false,
    super.key,
  });

  final bool loadPlacesOnStart;

  @override
  State<NavTripApp> createState() => _NavTripAppState();
}

class _NavTripAppState extends State<NavTripApp> {
  late final Future<void> _bootstrapFuture = _bootstrap();
  late final String _initialRoute = _resolveInitialRoute();
  bool _firebaseEnabled = false;

  String _resolveInitialRoute() {
    final path = Uri.base.path.trim();
    if (path.isEmpty || path == '/') {
      return '/';
    }
    return path.startsWith('/') ? path : '/$path';
  }

  Future<void> _bootstrap() async {
    try {
      await FirebaseConfig.load();
      _firebaseEnabled = FirebaseConfig.hasConfig;
      if (!_firebaseEnabled) {
        return;
      }

      await Firebase.initializeApp(options: FirebaseConfig.options)
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      _firebaseEnabled = false;
    } catch (_) {
      _firebaseEnabled = false;
    }
  }

  Map<String, WidgetBuilder> _bootstrapRoutes(WidgetBuilder fallbackBuilder) {
    return {
      '/': fallbackBuilder,
      '/login': fallbackBuilder,
      '/signup': fallbackBuilder,
      '/dashboard': fallbackBuilder,
      '/trip-details': fallbackBuilder,
      '/trip-map': fallbackBuilder,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            title: 'NavTrip AI',
            debugShowCheckedModeBanner: false,
            theme: NavTripStyles.theme(),
            darkTheme: NavTripStyles.darkTheme(),
            themeMode: ThemeMode.system,
            routes: _bootstrapRoutes((_) => const _BootstrapLoadingScreen()),
            initialRoute: _initialRoute,
          );
        }

        if (snapshot.hasError) {
          final message =
              snapshot.error?.toString() ?? 'Failed to initialize Firebase.';
          final missingFirebaseConfig = message.contains('FIREBASE_');
          final failureScreen = missingFirebaseConfig
              ? const _MissingFirebaseConfigScreen()
              : _StartupFailureScreen(error: snapshot.error);

          return MaterialApp(
            title: 'NavTrip AI',
            debugShowCheckedModeBanner: false,
            theme: NavTripStyles.theme(),
            darkTheme: NavTripStyles.darkTheme(),
            themeMode: ThemeMode.system,
            routes: _bootstrapRoutes((_) => failureScreen),
            initialRoute: _initialRoute,
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(enabled: _firebaseEnabled),
            ),
            Provider<ApiClient>(
              create: (_) => ApiClient(),
            ),
            ChangeNotifierProxyProvider<ApiClient, TripPlannerController>(
              create: (context) =>
                  TripPlannerController(context.read<ApiClient>()),
              update: (_, apiClient, controller) {
                return controller ?? TripPlannerController(apiClient);
              },
            ),
          ],
          child: _NavTripAppShell(
            initialRoute: _initialRoute,
            loadPlacesOnStart: widget.loadPlacesOnStart,
          ),
        );
      },
    );
  }
}

class _NavTripAppShell extends StatelessWidget {
  const _NavTripAppShell({
    required this.initialRoute,
    required this.loadPlacesOnStart,
  });

  final String initialRoute;
  final bool loadPlacesOnStart;

  String? _redirectTarget(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavTrip AI',
      debugShowCheckedModeBanner: false,
      theme: NavTripStyles.theme(),
      darkTheme: NavTripStyles.darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      routes: {
        '/': (_) => _HomeRouteGate(loadPlacesOnStart: loadPlacesOnStart),
        '/login': (context) =>
            LoginScreen(redirectTo: _redirectTarget(context)),
        '/signup': (context) =>
            SignUpScreen(redirectTo: _redirectTarget(context)),
        '/dashboard': (_) => const AuthGuard(
              protectedRoute: '/dashboard',
              child: DashboardScreen(),
            ),
        '/trip-details': (_) => const AuthGuard(
              protectedRoute: '/trip-details',
              child: TouristMapScreen(),
            ),
        '/trip-map': (_) => const AuthGuard(
              protectedRoute: '/trip-map',
              child: TouristMapScreen(),
            ),
      },
    );
  }
}

class _HomeRouteGate extends StatefulWidget {
  const _HomeRouteGate({required this.loadPlacesOnStart});

  final bool loadPlacesOnStart;

  @override
  State<_HomeRouteGate> createState() => _HomeRouteGateState();
}

class _HomeRouteGateState extends State<_HomeRouteGate> {
  bool _redirectQueued = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isReady) {
      return const _BootstrapLoadingScreen();
    }

    if (auth.isAuthenticated && auth.needsVerification && !_redirectQueued) {
      _redirectQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed('/signup');
      });
      return const _BootstrapLoadingScreen();
    }

    if (auth.isAuthenticated && !_redirectQueued) {
      _redirectQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed('/dashboard');
      });
    }

    return HomeScreen(loadPlacesOnStart: widget.loadPlacesOnStart);
  }
}

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _StartupFailureScreen extends StatelessWidget {
  const _StartupFailureScreen({this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    final message = error?.toString().trim();
    return Scaffold(
      body: PaperTexture(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: NavTripStyles.paperCard(radius: 14),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Startup failed',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: NavTripPalette.terracottaDeep,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'NavTrip AI could not finish its initial setup. The most likely cause is Firebase config loading or an invalid auth environment.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (message != null && message.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: NavTripPalette.mutedInk,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingFirebaseConfigScreen extends StatelessWidget {
  const _MissingFirebaseConfigScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperTexture(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: NavTripStyles.paperCard(radius: 14),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase config missing',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: NavTripPalette.terracottaDeep,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add the Firebase values to frontend/.env, then restart the app.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The app now boots with Firebase Auth, but it cannot initialize without the project keys.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: NavTripPalette.mutedInk,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
