import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/trip_planner_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/login_screen.dart';
import 'screens/tourist_map_screen.dart';
import 'services/api_client.dart';
import 'theme/navtrip_theme.dart';

void main() {
  runApp(const NavTripApp());
}

class NavTripApp extends StatelessWidget {
  const NavTripApp({
    this.loadPlacesOnStart = false,
    super.key,
  });

  final bool loadPlacesOnStart;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
      child: MaterialApp(
        title: 'NavTrip AI',
        debugShowCheckedModeBanner: false,
        theme: NavTripStyles.theme(),
        routes: {
          '/': (_) => HomeScreen(loadPlacesOnStart: loadPlacesOnStart),
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/trip-details': (_) => const ItineraryScreen(),
          '/trip-map': (_) => const TouristMapScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
