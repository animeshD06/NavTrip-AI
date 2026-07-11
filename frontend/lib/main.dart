import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/auth_config.dart';
import 'providers/auth_provider.dart';
import 'providers/trip_planner_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/tourist_map_screen.dart';
import 'services/api_client.dart';
import 'services/noop_clerk_file_cache.dart';
import 'theme/navtrip_theme.dart';
import 'widgets/auth_guard.dart';

void main() {
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
  late final Future<void> _bootstrapFuture = AuthConfig.load();

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
            home: const _ClerkBootstrapScreen(),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            title: 'NavTrip AI',
            debugShowCheckedModeBanner: false,
            theme: NavTripStyles.theme(),
            home: _StartupFailureScreen(error: snapshot.error),
          );
        }

        if (!AuthConfig.hasPublishableKey) {
          return MaterialApp(
            title: 'NavTrip AI',
            debugShowCheckedModeBanner: false,
            theme: NavTripStyles.theme(),
            home: const _MissingAuthConfigScreen(),
          );
        }

        return ClerkAuth(
          config: ClerkAuthConfig(
            fileCache: kIsWeb ? const NoOpClerkFileCache() : null,
            persistor: kIsWeb ? clerk.Persistor.none : null,
            publishableKey: AuthConfig.publishableKey,
            redirectionGenerator: AuthConfig.redirectUriGenerator,
            deepLinkStream: AuthConfig.deepLinkStream(),
            loading: const _ClerkBootstrapScreen(),
          ),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>(
                create: (_) => AuthProvider(),
              ),
              Provider<ApiClient>(
                create: (_) => ApiClient(),
              ),
              ChangeNotifierProxyProvider<ApiClient, TripPlannerController>(
                create: (context) => TripPlannerController(context.read<ApiClient>()),
                update: (_, apiClient, controller) {
                  return controller ?? TripPlannerController(apiClient);
                },
              ),
            ],
            child: _ClerkBoundApp(loadPlacesOnStart: widget.loadPlacesOnStart),
          ),
        );
      },
    );
  }
}

class _ClerkBoundApp extends StatefulWidget {
  const _ClerkBoundApp({required this.loadPlacesOnStart});

  final bool loadPlacesOnStart;

  @override
  State<_ClerkBoundApp> createState() => _ClerkBoundAppState();
}

class _ClerkBoundAppState extends State<_ClerkBoundApp> {
  bool _restoredSession = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = ClerkAuth.of(context);
    final authProvider = context.read<AuthProvider>();
    authProvider.attach(authState);

    if (!_restoredSession) {
      _restoredSession = true;
      authProvider.restoreSession();
    }
  }

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
      routes: {
        '/': (_) => _HomeRouteGate(loadPlacesOnStart: widget.loadPlacesOnStart),
        '/login': (context) => LoginScreen(redirectTo: _redirectTarget(context)),
        '/signup': (context) => SignUpScreen(redirectTo: _redirectTarget(context)),
        '/dashboard': (_) => const AuthGuard(
              protectedRoute: '/dashboard',
              child: DashboardScreen(),
            ),
        '/trip-details': (_) => const AuthGuard(
              protectedRoute: '/trip-details',
              child: ItineraryScreen(),
            ),
        '/trip-map': (_) => const AuthGuard(
              protectedRoute: '/trip-map',
              child: TouristMapScreen(),
            ),
      },
      initialRoute: '/',
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
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: NavTripPalette.terracottaDeep,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'NavTrip AI could not finish its initial setup. The most likely cause is Clerk config loading or an invalid auth environment.',
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

class _ClerkBootstrapScreen extends StatelessWidget {
  const _ClerkBootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: NavTripStyles.theme(),
      home: Scaffold(
        body: PaperTexture(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                decoration: NavTripStyles.paperCard(radius: 18),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Starting NavTrip AI',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: NavTripPalette.terracottaDeep,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Clerk is loading your session and redirect settings.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _MissingAuthConfigScreen extends StatelessWidget {
  const _MissingAuthConfigScreen();

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
                      'Clerk publishable key missing',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: NavTripPalette.terracottaDeep,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add CLERK_PUBLISHABLE_KEY to frontend/.env, then restart the app.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The app now boots with Clerk Auth, but it cannot initialize without the dashboard key.',
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










