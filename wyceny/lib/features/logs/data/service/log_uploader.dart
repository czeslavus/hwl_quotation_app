import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LogUploader {
  final Dio dio;
  final Uri endpoint; // np. Uri.parse("https://api.example.com/logs/upload");

  LogUploader({required this.dio, required this.endpoint});

  Future<Map<String, String>> _headers() async {
    final info = await PackageInfo.fromPlatform();
    return {
      'X-App-Name': info.appName,
      'X-App-Version': info.version,
      'Content-Type': 'application/octet-stream',
    };
  }

  /// POST surowych bajtów pliku (query: filename, ts)
  Future<Response<dynamic>> uploadFile(File file) async {
    final bytes = await file.readAsBytes();
    final headers = await _headers();

    final url = endpoint.replace(queryParameters: {
      ...endpoint.queryParameters,
      'filename': file.uri.pathSegments.last,
      'ts': file.lastModifiedSync().toUtc().toIso8601String(),
    }).toString();

    return dio.post(
      url,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: headers,
        responseType: ResponseType.json,
        followRedirects: false,
        validateStatus: (code) => code != null && code >= 200 && code < 400,
      ),
    );
  }

  Future<void> uploadAll(List<File> files) async {
    for (final f in files) {
      final res = await uploadFile(f);
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        await f.rename("${f.path}.sent");
      } else {
        throw Exception("Upload failed (${res.statusCode}): ${res.data}");
      }
    }
  }
}
