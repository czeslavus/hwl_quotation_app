enum AppEnv { dev, staging, prod }

class EnvConfig {
  final AppEnv env;
  final String baseUrl;
  final String orsKey;
  final bool enableHttpLogging;

  const EnvConfig({
    required this.env,
    required this.baseUrl,
    required this.orsKey,
    this.enableHttpLogging = false,
  });
}
