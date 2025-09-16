import 'dart:async';
import 'package:wyceny/features/logs/data/service/caller_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

import 'package:wyceny/features/logs/data/service/file_log_output_stub.dart'
if (dart.library.io) 'file_log_output_io.dart';

class ConsoleSimpleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      // ignore: avoid_print
      print(line);
    }
  }
}

class LogService {
  late final Logger logger;

  LogService({
    int maxBytes = 2 * 1024 * 1024,
    int maxFiles = 5,
    Level level = Level.debug,
  }) {
    final outputs = <LogOutput>[
      createFileLogOutput(maxBytes: maxBytes, maxFiles: maxFiles),
      ConsoleSimpleOutput(),
    ];

    logger = CallerLogger(
      level: level,
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 5,
        lineLength: 80,
        colors: false,
        printEmojis: true,
        // jeśli masz tę opcję w swojej wersji loggera, możesz też:
        // stackTraceBeginIndex: 0,
        // noBoxingByDefault: false,
      ),
      output: MultiOutput(outputs),
    );

    _installGlobalHandlers();
  }

  void _installGlobalHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.e(
        'FlutterError',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
    runZonedGuarded(() {
    }, (error, stack) {
      logger.e('Uncaught zone error', error: error, stackTrace: stack);
    });
  }

  /// Ścieżka katalogu logów (IO) lub null (web).
  Future<String?> getLogsDirPath() => platformLogsDirPath();

  /// Listuje ścieżki plików logów (IO) lub pustą listę (web).
  Future<List<String>> listLogFiles() => platformListLogFiles();
}
