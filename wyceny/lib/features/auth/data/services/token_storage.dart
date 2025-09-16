abstract class TokenStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

const kAccessTokenKey = 'access_token';
const kRefreshTokenKey = 'refresh_token';
const kDeviceIdKey    = 'device_id';