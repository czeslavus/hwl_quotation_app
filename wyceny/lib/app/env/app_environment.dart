enum AppEnv { dev, staging, prod }

class EnvConfig {
  final AppEnv env;
  final String baseUrl;
  final bool enableHttpLogging;

  const EnvConfig({
    required this.env,
    required this.baseUrl,
    this.enableHttpLogging = false,
  });
}
