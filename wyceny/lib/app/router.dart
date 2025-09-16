import 'package:e_kierowca_app/features/dist_rides/ui/viewmodels/dist_ride_stops_viewmodel.dart';
import 'package:e_kierowca_app/features/dist_rides/ui/widgets/dist_ride_stops_screen.dart';
import 'package:e_kierowca_app/features/dist_rides/ui/widgets/dist_rides_screen.dart';
import 'package:e_kierowca_app/features/driver_stats/ui/widgets/driver_stats_screen.dart';
import 'package:e_kierowca_app/features/ftl_rides/ui/widgets/ftl_rides_screen.dart';
import 'package:e_kierowca_app/features/location_history/ui/widgets/location_history_map_screen.dart';
import 'package:e_kierowca_app/features/messages/ui/widgets/messages_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:e_kierowca_app/features/auth/ui/widgets/login_screen.dart';
import 'package:e_kierowca_app/features/line_rides/ui/widgets/line_rides_screen.dart';
import 'package:e_kierowca_app/features/line_rides/ui/widgets/line_rides_stop_screen.dart';
import 'package:e_kierowca_app/features/logs/ui/widgets/logs_screen.dart';
import 'package:e_kierowca_app/features/splash/ui/widgets/splash_screen.dart';
import 'package:e_kierowca_app/app/app_scaffold.dart';
import 'package:e_kierowca_app/app/auth.dart';
import 'package:e_kierowca_app/features/preferences/ui/widgets/preferences_screen.dart';
import 'package:e_kierowca_app/app/di/locator.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AuthState auth) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: auth,
    redirect: (context, state) {
      // Splash jest zawsze dozwolony – tam czekamy na init()
      if (state.matchedLocation == '/splash') return null;

      final loggedIn = auth.isLoggedIn;
      final loggingIn = state.matchedLocation == '/login';
      if (!auth.isInitialized) return '/splash';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/map';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
        const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
        const NoTransitionPage(child: LoginScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppScaffold(shell: shell),
        branches: [
          // Distribution
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dist',
                name: 'dist',
                pageBuilder: (context, state) =>
                const NoTransitionPage(child: DistRidesScreen()),
                routes: [
                  GoRoute(
                    path: 'stops/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      return Provider<DistRideStopsViewModel>(
                          create: (_)=>getIt<DistRideStopsViewModel>(param1:id),
                          dispose: (_, vm) => vm.dispose(),
                          child: DistRideStopsScreen(),
                      );
//                      return DistRideStopsScreen(id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Line
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/line',
                name: 'line',
                pageBuilder: (context, state) =>
                const NoTransitionPage(child: LineRidesScreen()),
                routes: [
                  GoRoute(
                    path: 'stop/:transitNr/:destinationBranch',
                  builder: (context, state) {
                    final transitNr = state.pathParameters['transitNr']!;
                    final destinationBranch = state.pathParameters['destinationBranch']!;
                    return LineRideStopScreen(
                      transitNr: transitNr,
                      destinationBranch: destinationBranch,
                    );
                  },),
                ],
              ),
            ],
          ),
          // FTL
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ftl',
                name: 'ftl',
                pageBuilder: (context, state) =>
                const NoTransitionPage(child: FtlRidesScreen()),
                routes: [
//                   GoRoute(
//                     path: 'stops/:id',
//                     builder: (context, state) {
//                       final id = state.pathParameters['id'];
//                       return Provider<FtlRideStopsViewModel>(
//                         create: (_)=>getIt<FtlRideStopsViewModel>(param1:id),
//                         dispose: (_, vm) => vm.dispose(),
//                         child: FtlRideStopsScreen(),
//                       );
// //                      return DistRideStopsScreen(id);
//                     },
//                   ),
                ],
              ),
            ],
          ),
          // Notifications
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifs',
                name: 'notifs',
                pageBuilder: (context, state) =>
                const NoTransitionPage(child: MessagesScreen()),
                routes: [
//                   GoRoute(
//                     path: 'stops/:id',
//                     builder: (context, state) {
//                       final id = state.pathParameters['id'];
//                       return Provider<DistRideStopsViewModel>(
//                         create: (_)=>getIt<DistRideStopsViewModel>(param1:id),
//                         dispose: (_, vm) => vm.dispose(),
//                         child: DistRideStopsScreen(),
//                       );
// //                      return DistRideStopsScreen(id);
//                     },
//                   ),
                ],
              ),
            ],
          ),
          // Statistics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                name: 'stats',
                pageBuilder: (context, state) =>
                const NoTransitionPage(child: DriverStatsScreen()),
                routes: [
                ],
              ),
            ],
          ),
          // History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                name: 'map',
                pageBuilder: (context, state) =>
                const NoTransitionPage(child: LocationHistoryMapScreen()),
              ),
            ],
          ),
          // Preferences
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/preferences',
                name: 'preferences',
                pageBuilder: (context, state) =>
                const NoTransitionPage(child: PreferencesScreen()),
                routes: [
                  GoRoute(
                    path: 'logs',
                    builder: (context, state) {
                      return LogsScreen(logService: getIt(),);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
