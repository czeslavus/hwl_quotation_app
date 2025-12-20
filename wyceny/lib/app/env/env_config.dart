import 'package:wyceny/app/env/app_environment.dart';

class EnvLoader {
  static const apiHost = 'https://ekierowca-testowy.hwl.pl/api';

  static EnvConfig fromDartDefine() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    const base   = String.fromEnvironment('BASE_URL', defaultValue: apiHost);

    final env = switch (flavor) {
      'prod'    => AppEnv.prod,
      'staging' => AppEnv.staging,
      _         => AppEnv.dev,
    };

    final enableLog = env != AppEnv.prod;

    return EnvConfig(env: env, baseUrl: base, enableHttpLogging: enableLog);
  }
}
