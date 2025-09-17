// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Wyceny przejazdów międzynarodowych HWL';

  @override
  String get signIn_title => 'Zaloguj się';

  @override
  String greeting(String name) {
    return 'Dzień dobry $name!';
  }

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementy',
      one: '1 element',
      zero: 'Brak elementów',
    );
    return '$_temp0';
  }

  @override
  String get app_companyName => 'Hellmann Worldwide Logistics';

  @override
  String get nav_quote => 'Wycena';

  @override
  String get nav_order => 'Zamówienie';

  @override
  String get nav_history => 'Historia';

  @override
  String get nav_settings => 'Ustawienia';

  @override
  String get menu_account => 'Konto';

  @override
  String get menu_settings => 'Ustawienia';

  @override
  String get menu_logout => 'Wyloguj';

  @override
  String get frame_exampleSubscreen => 'Przykładowy sub-ekran';

  @override
  String frame_placeholder(String title) {
    return 'Tu dodaj treść ekranu \"$title\".';
  }

  @override
  String get recover_title => 'Odzyskiwanie hasła';

  @override
  String get recover_sendCode => 'Wyślij kod';

  @override
  String get recover_codeLabel => 'Kod z SMS';

  @override
  String get recover_codeRequired => 'Podaj kod';

  @override
  String get recover_newPasswordLabel => 'Nowe hasło';

  @override
  String get recover_repeatPasswordLabel => 'Powtórz hasło';

  @override
  String get recover_repeatPasswordRequired => 'Powtórz hasło';

  @override
  String get recover_passwordsMismatch => 'Hasła się nie zgadzają';

  @override
  String get recover_setPassword => 'Ustaw nowe hasło';

  @override
  String get recover_codeSentInfo => 'Kod został wysłany SMS-em';

  @override
  String get recover_invalidLoginOrPhone =>
      'Nieprawidłowy login lub brak numeru telefonu';

  @override
  String get recover_invalidCodeOrPolicy =>
      'Nieprawidłowy kod lub hasło nie spełnia wymagań';

  @override
  String get recover_passwordChangedSnack =>
      'Hasło zostało zmienione. Możesz się zalogować.';

  @override
  String get common_networkError => 'Błąd połączenia. Sprawdź internet.';

  @override
  String get common_unknownError => 'Wystąpił nieoczekiwany błąd.';

  @override
  String get auth_loginTitle => 'Zaloguj się';

  @override
  String get auth_usernameLabel => 'Użytkownik';

  @override
  String get auth_usernameRequired => 'Podaj nazwę użytkownika';

  @override
  String get auth_passwordLabel => 'Hasło';

  @override
  String get auth_passwordRequired => 'Podaj hasło';

  @override
  String get auth_loginButton => 'Zaloguj';

  @override
  String get auth_forgotPassword => 'Nie pamiętasz hasła?';

  @override
  String get auth_enterUsernameSnack => 'Podaj nazwę użytkownika.';

  @override
  String get auth_recoverSentSnack => 'Wysłano instrukcje odzyskiwania hasła.';

  @override
  String get auth_showPassword => 'Pokaż hasło';

  @override
  String get auth_hidePassword => 'Ukryj hasło';

  @override
  String get login_invalidCredentials => 'Nieprawidłowe dane logowania.';

  @override
  String get login_network => 'Błąd połączenia. Sprawdź internet.';

  @override
  String get login_unknown => 'Wystąpił nieoczekiwany błąd.';

  @override
  String get settings_language => 'Język aplikacji';

  @override
  String get settings_lang_system => 'Język systemowy';
}
