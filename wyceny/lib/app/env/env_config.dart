import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wyceny/app/env/app_environment.dart';

class EnvLoader {
  static const apiHost = 'https://ekierowca-testowy.hwl.pl/api';
  static const defaultRouteColor = Color(0xFF2196F3);

  static EnvConfig fromDartDefine() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    const base   = String.fromEnvironment('BASE_URL', defaultValue: apiHost);
    final orsApiKey = dotenv.env['ORS_API_KEY']
        ?? const String.fromEnvironment('ORS_API_KEY', defaultValue: '');
    final hereApiKey = dotenv.env['HERE_API_KEY']
        ?? const String.fromEnvironment('HERE_API_KEY', defaultValue: '');

    final env = switch (flavor) {
      'prod'    => AppEnv.prod,
      'staging' => AppEnv.staging,
      _         => AppEnv.dev,
    };

    final enableLog = env != AppEnv.prod;

    return EnvConfig(
      env: env,
      baseUrl: base,
      orsKey: orsApiKey,
      hereKey: hereApiKey,
      routeColor: defaultRouteColor,
      enableHttpLogging: enableLog,
    );
  }
}
