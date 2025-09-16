import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileLogOutputIo extends LogOutput {
  final int maxBytes;   // np. 2 MB
  final int maxFiles;   // np. 5 plików rotacji
  late final Future<File> Function() _resolveFile;

  FileLogOutputIo({this.maxBytes = 2 * 1024 * 1024, this.maxFiles = 5}) {
    _resolveFile = _createOrGetFile;
  }

  @override
  void output(OutputEvent event) async {
    final file = await _resolveFile();
    final sink = file.openWrite(mode: FileMode.append);
    for (final line in event.lines) {
      sink.writeln(line);
    }
    await sink.flush();
    await sink.close();
    await _rotateIfNeeded(file);
  }

  Future<File> _createOrGetFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final day = DateTime.now();
    final name = "app-${day.year}${_2(day.month)}${_2(day.day)}.log";
    final file = File("${dir.path}/logs/$name");
    await file.parent.create(recursive: true);
    if (!await file.exists()) await file.create();
    return file;
  }

  Future<void> _rotateIfNeeded(File file) async {
    if (await file.length() <= maxBytes) return;

    // od najstarszego do nowszych
    for (int i = maxFiles - 1; i >= 1; i--) {
      final rotated = File("${file.path}.$i");
      if (await rotated.exists()) {
        if (i == maxFiles - 1) {
          await rotated.delete(); // usuń najstarszy
        } else {
          await rotated.rename("${file.path}.${i + 1}");
        }
      }
    }
    if (await file.exists()) {
      await file.rename("${file.path}.1");
    }
    // utwórz nowy bieżący
    await File(file.path).create();
  }

  String _2(int v) => v.toString().padLeft(2, '0');
}

/// Fabryka używana przez logger_service.dart (IO)
LogOutput createFileLogOutput({int maxBytes = 2 * 1024 * 1024, int maxFiles = 5}) =>
    FileLogOutputIo(maxBytes: maxBytes, maxFiles: maxFiles);

/// Ścieżka katalogu logów (IO)
Future<String?> platformLogsDirPath() async {
  final dir = await getApplicationDocumentsDirectory();
  final logs = Directory("${dir.path}/logs");
  await logs.create(recursive: true);
  return logs.path;
}

/// Lista ścieżek plików logów (IO)
Future<List<String>> platformListLogFiles() async {
  final path = await platformLogsDirPath();
  if (path == null) return [];
  final dir = Directory(path);
  final files = dir.listSync().whereType<File>().toList();
  files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  return files.map((f) => f.path).toList();
}
