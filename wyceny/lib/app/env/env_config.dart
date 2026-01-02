import 'package:wyceny/app/env/app_environment.dart';

class EnvLoader {
  static const apiHost = 'https://ekierowca-testowy.hwl.pl/api';
  static const orsKeyDef = 'xyx';

  static EnvConfig fromDartDefine() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    const base   = String.fromEnvironment('BASE_URL', defaultValue: apiHost);
    const orsApiKey = String.fromEnvironment('ORS_API_KEY', defaultValue: orsKeyDef);

    final env = switch (flavor) {
      'prod'    => AppEnv.prod,
      'staging' => AppEnv.staging,
      _         => AppEnv.dev,
    };

    final enableLog = env != AppEnv.prod;

    return EnvConfig(env: env, baseUrl: base, orsKey: orsApiKey, enableHttpLogging: enableLog);
  }
}
