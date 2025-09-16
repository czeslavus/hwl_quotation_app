import 'package:e_kierowca_app/app/env/app_environment.dart';

class EnvLoader {
  static const apiHost = 'https://0ba23e508118.ngrok-free.app/api';

  static EnvConfig fromDartDefine() {
    // Przekazuj: --dart-define=FLAVOR=dev  oraz  --dart-define=BASE_URL=https://api.dev.example.com
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
