
abstract class AuthService {

  String get user;

  Future<bool> init();

  Future<bool> login(String username, String password);

  Future<void> logout();

  /// Odświeża access token poprzez zapytanie do api z refresh token
  Future<bool> refreshAccessToken();

  /// Rozpoczyna procedurę odzyskiwania hasła
  Future<bool> recoverRequest(String username);

  /// ustawia nowe hasło dla użytkownika
  Future<bool> recoverSetPassword(
      String username,
      String code,
      String password,
      );
}
