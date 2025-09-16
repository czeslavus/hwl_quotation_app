import '../token_storage.dart';

TokenStorage createPlatformTokenStorage() => MemoryWebTokenStorage();

class MemoryWebTokenStorage implements TokenStorage {
  final Map<String, String> _mem = {};

  @override
  Future<void> write(String key, String value) async {
    _mem[key] = value;
  }

  @override
  Future<String?> read(String key) async => _mem[key];

  @override
  Future<void> delete(String key) async { _mem.remove(key); }
}