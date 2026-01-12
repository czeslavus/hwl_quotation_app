enum AppEnv { dev, staging, prod }

class EnvConfig {
  final AppEnv env;
  final String baseUrl;
  final String orsKey;
  final String hereKey;
  final bool enableHttpLogging;

  const EnvConfig({
    required this.env,
    required this.baseUrl,
    required this.orsKey,
    required this.hereKey,
    this.enableHttpLogging = false,
  });
}
