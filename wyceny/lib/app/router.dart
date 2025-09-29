import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/features/auth/ui/widgets/login_screen.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotations_screen.dart';
import 'package:wyceny/features/splash/ui/widgets/splash_screen.dart';
import 'package:wyceny/app/app_scaffold.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/app/di/locator.dart';

import 'package:wyceny/features/auth/ui/widgets/recover_set_password_screen.dart';
import 'package:wyceny/features/logs/ui/widgets/logs_screen.dart';
import 'package:wyceny/features/orders/ui/widgets/orders_screen.dart';
import 'package:wyceny/features/preferences/ui/widgets/preferences_screen.dart';

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
      final recovering = state.matchedLocation == '/recover';

      if (!auth.isInitialized) return '/splash';

      // Niezalogowany – dozwolone tylko login i recover
      if (!loggedIn && !(loggingIn || recovering)) return '/login';

      // Zalogowany – nie powinien siedzieć na login/recover
      if (loggedIn && (loggingIn || recovering)) return '/quote';
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
      GoRoute(
        path: '/recover',
        pageBuilder: (context, state) =>
        const NoTransitionPage(child: RecoverSetPasswordScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppScaffold(shell: shell),
        branches: [
          // Distribution
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quote',
                name: 'quote',
                pageBuilder: (context, state) {
                  return MaterialPage(
                    key: state.pageKey,
                    child: ChangeNotifierProvider(
                      create: (_) => getIt<QuotationViewModel>()..init(),
                      child: const QuotationScreen(),
                    ),
                  );
                }
              ),
            ],
          ),
          // Line
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/order',
                name: 'order',
                pageBuilder: (context, state) =>
                const NoTransitionPage(child: OrdersScreen()),
                // routes: [
                //   GoRoute(
                //     path: 'stop/:transitNr/:destinationBranch',
                //   builder: (context, state) {
                //     final transitNr = state.pathParameters['transitNr']!;
                //     final destinationBranch = state.pathParameters['destinationBranch']!;
                //     return LineRideStopScreen(
                //       transitNr: transitNr,
                //       destinationBranch: destinationBranch,
                //     );
                //   },),
                // ],
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
