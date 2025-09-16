// lib/core/logging/caller_logger.dart
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CallerLogger extends Logger {
  CallerLogger({
    Level super.level = Level.debug,
    super.filter,
    super.printer,
    super.output,
  });

  @override
  void log(
      Level level,
      dynamic message, {
        Object? error,
        StackTrace? stackTrace,
        DateTime? time,
      }) {
    // Jeśli użytkownik już podał stackTrace (np. w logger.e) – nie nadpisujemy.
    stackTrace ??= _callerStack();

    super.log(
      level,
      message,
      error: error,
      stackTrace: stackTrace,
      time: time,
    );
  }

  // Wytnij parę pierwszych ramek (to my + Logger)
  StackTrace _callerStack() {
    final skip = kIsWeb ? 4 : 3; // Web ma odrobinę głębszy stos
    final lines = StackTrace.current.toString().split('\n');
    final pruned = lines.skip(skip).join('\n');
    return StackTrace.fromString(pruned);
  }
}
