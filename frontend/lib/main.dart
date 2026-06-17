import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/trip_planner_controller.dart';
import 'screens/home_screen.dart';
import 'services/api_client.dart';

void main() {
  runApp(const NavTripApp());
}

class NavTripApp extends StatelessWidget {
  const NavTripApp({
    this.loadPlacesOnStart = true,
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff0f766e),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: HomeScreen(loadPlacesOnStart: loadPlacesOnStart),
      ),
    );
  }
}
