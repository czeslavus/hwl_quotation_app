import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'app/auth.dart';
import 'app/di/locator.dart';

import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDI();

  final auth =getIt<AuthState>();
  runApp(AuthScope(
    notifier: auth,
    child: MyApp(auth: auth),
  ));
}

class MyApp extends StatelessWidget {
  final AuthState auth;
  const MyApp({super.key, required this.auth});


  @override
  Widget build(BuildContext context) {
    final router = getIt<GoRouter>();
    return MaterialApp.router(
      title: 'HWL Quotation App',

      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routerConfig: router,
    );
  }
}