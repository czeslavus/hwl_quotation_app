import 'package:logger/logger.dart';

/// No-op na web — nie zapisuje do pliku.
class NoopFileLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {/* nic */}
}

/// Fabryka używana przez logger_service.dart
LogOutput createFileLogOutput({int maxBytes = 2 * 1024 * 1024, int maxFiles = 5}) =>
    NoopFileLogOutput();

/// Ścieżka katalogu logów (web → null)
Future<String?> platformLogsDirPath() async => null;

/// Lista ścieżek plików logów (web → pusta)
Future<List<String>> platformListLogFiles() async => const [];
