import 'package:dio/dio.dart';

class AuthRules {
  static const kSkipAuth = 'skipAuth'; // RequestOptions.extra flag

  static final List<Pattern> _defaultExemptions = <Pattern>[
    RegExp(r'/auth($|/)'),         // /auth, /auth/login, /auth/anything
    // ewentualnie:
    // RegExp(r'/oauth2/.*'),      // jeśli używasz zewnętrznego oauth2
  ];

  /// True, jeśli request powinien pominąć Authorization (header) i mechanizmy refresh.
  static bool isAuthExempt(RequestOptions o, {List<Pattern>? extraExemptions}) {
    // 1) Twardy override per-request
    if (o.extra[kSkipAuth] == true) return true;

    // 2) Sprawdź wzorce ścieżek
    final path = o.uri.path.toLowerCase();
    final all = [..._defaultExemptions, ...?extraExemptions];
    for (final p in all) {
      if (p is RegExp) {
        if (p.hasMatch(path)) return true;
      } else {
        // String/Pattern fallback – prosta zawartość
        if (path.contains(p.toString().toLowerCase())) return true;
      }
    }
    return false;
  }
}
