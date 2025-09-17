// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HWL International Quotations';

  @override
  String get signIn_title => 'Sign in';

  @override
  String greeting(String name) {
    return 'Hello $name!';
  }

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get app_companyName => 'Hellmann Worldwide Logistics';

  @override
  String get nav_quote => 'Quote';

  @override
  String get nav_order => 'Order';

  @override
  String get nav_history => 'History';

  @override
  String get nav_settings => 'Settings';

  @override
  String get menu_account => 'Account';

  @override
  String get menu_settings => 'Settings';

  @override
  String get menu_logout => 'Log out';

  @override
  String get frame_exampleSubscreen => 'Example sub-screen';

  @override
  String frame_placeholder(String title) {
    return 'Add the content of \"$title\" screen here.';
  }

  @override
  String get recover_title => 'Password recovery';

  @override
  String get recover_sendCode => 'Send code';

  @override
  String get recover_codeLabel => 'SMS code';

  @override
  String get recover_codeRequired => 'Enter the code';

  @override
  String get recover_newPasswordLabel => 'New password';

  @override
  String get recover_repeatPasswordLabel => 'Repeat password';

  @override
  String get recover_repeatPasswordRequired => 'Repeat the password';

  @override
  String get recover_passwordsMismatch => 'Passwords do not match';

  @override
  String get recover_setPassword => 'Set new password';

  @override
  String get recover_codeSentInfo => 'The code has been sent via SMS';

  @override
  String get recover_invalidLoginOrPhone =>
      'Invalid login or missing phone number';

  @override
  String get recover_invalidCodeOrPolicy =>
      'Invalid code or password does not meet requirements';

  @override
  String get recover_passwordChangedSnack =>
      'Password changed. You can sign in now.';

  @override
  String get common_networkError => 'Connection error. Check your internet.';

  @override
  String get common_unknownError => 'An unexpected error occurred.';

  @override
  String get auth_loginTitle => 'Sign in';

  @override
  String get auth_usernameLabel => 'Username';

  @override
  String get auth_usernameRequired => 'Please enter your username';

  @override
  String get auth_passwordLabel => 'Password';

  @override
  String get auth_passwordRequired => 'Please enter your password';

  @override
  String get auth_loginButton => 'Sign in';

  @override
  String get auth_forgotPassword => 'Forgot password?';

  @override
  String get auth_enterUsernameSnack => 'Enter your username.';

  @override
  String get auth_recoverSentSnack => 'Password recovery instructions sent.';

  @override
  String get auth_showPassword => 'Show password';

  @override
  String get auth_hidePassword => 'Hide password';

  @override
  String get login_invalidCredentials => 'Invalid username or password.';

  @override
  String get login_network => 'Connection error. Check your internet.';

  @override
  String get login_unknown => 'An unexpected error occurred.';

  @override
  String get settings_language => 'App language';

  @override
  String get settings_lang_system => 'System language';
}
