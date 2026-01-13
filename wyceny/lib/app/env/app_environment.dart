import 'dart:ui';

enum AppEnv { dev, staging, prod }

class EnvConfig {
  final AppEnv env;
  final String baseUrl;
  final String orsKey;
  final String hereKey;
  final Color routeColor;
  final bool enableHttpLogging;

  const EnvConfig({
    required this.env,
    required this.baseUrl,
    required this.orsKey,
    required this.hereKey,
    required this.routeColor,
    this.enableHttpLogging = false,
  });
}
