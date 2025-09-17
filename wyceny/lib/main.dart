import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:wyceny/app/locale_controller.dart';
import 'app/auth.dart';
import 'app/di/locator.dart';

import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDI();

  final lc = getIt<LocaleController>();
  await lc.load();

  final auth =getIt<AuthState>();
  runApp(AuthScope(
    notifier: auth,
    child: MyApp(auth: auth, lc: lc),
  ));
}

class MyApp extends StatelessWidget {
  final AuthState auth;
  final LocaleController lc;
  const MyApp({super.key, required this.auth, required this.lc});


  @override
  Widget build(BuildContext context) {
    final router = getIt<GoRouter>();

    return ListenableBuilder(
        listenable: lc,
        builder: (_, __) {
          return MaterialApp.router(
            locale: lc.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            title: 'HWL Quotation App',
            onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
            theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
            routerConfig: router,
          );

        },
    );
  }
}