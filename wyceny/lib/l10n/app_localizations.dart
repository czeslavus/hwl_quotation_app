import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HWL International Quotations'**
  String get appTitle;

  /// No description provided for @signIn_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn_title;

  /// Greets the user by name.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}!'**
  String greeting(String name);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemsCount(num count);

  /// No description provided for @app_companyName.
  ///
  /// In en, this message translates to:
  /// **'Hellmann Worldwide Logistics'**
  String get app_companyName;

  /// No description provided for @nav_quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get nav_quote;

  /// No description provided for @nav_order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get nav_order;

  /// No description provided for @nav_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get nav_history;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @menu_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get menu_account;

  /// No description provided for @menu_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menu_settings;

  /// No description provided for @menu_logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get menu_logout;

  /// No description provided for @frame_exampleSubscreen.
  ///
  /// In en, this message translates to:
  /// **'Example sub-screen'**
  String get frame_exampleSubscreen;

  /// No description provided for @frame_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Add the content of \"{title}\" screen here.'**
  String frame_placeholder(String title);

  /// No description provided for @recover_title.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get recover_title;

  /// No description provided for @recover_sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get recover_sendCode;

  /// No description provided for @recover_codeLabel.
  ///
  /// In en, this message translates to:
  /// **'SMS code'**
  String get recover_codeLabel;

  /// No description provided for @recover_codeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get recover_codeRequired;

  /// No description provided for @recover_newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get recover_newPasswordLabel;

  /// No description provided for @recover_repeatPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get recover_repeatPasswordLabel;

  /// No description provided for @recover_repeatPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get recover_repeatPasswordRequired;

  /// No description provided for @recover_passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get recover_passwordsMismatch;

  /// No description provided for @recover_setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get recover_setPassword;

  /// No description provided for @recover_codeSentInfo.
  ///
  /// In en, this message translates to:
  /// **'The code has been sent via SMS'**
  String get recover_codeSentInfo;

  /// No description provided for @recover_invalidLoginOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid login or missing phone number'**
  String get recover_invalidLoginOrPhone;

  /// No description provided for @recover_invalidCodeOrPolicy.
  ///
  /// In en, this message translates to:
  /// **'Invalid code or password does not meet requirements'**
  String get recover_invalidCodeOrPolicy;

  /// No description provided for @recover_passwordChangedSnack.
  ///
  /// In en, this message translates to:
  /// **'Password changed. You can sign in now.'**
  String get recover_passwordChangedSnack;

  /// No description provided for @common_networkError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet.'**
  String get common_networkError;

  /// No description provided for @common_unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get common_unknownError;

  /// No description provided for @auth_loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get auth_loginTitle;

  /// No description provided for @auth_usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get auth_usernameLabel;

  /// No description provided for @auth_usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get auth_usernameRequired;

  /// No description provided for @auth_passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_passwordLabel;

  /// No description provided for @auth_passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get auth_passwordRequired;

  /// No description provided for @auth_loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get auth_loginButton;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get auth_forgotPassword;

  /// No description provided for @auth_enterUsernameSnack.
  ///
  /// In en, this message translates to:
  /// **'Enter your username.'**
  String get auth_enterUsernameSnack;

  /// No description provided for @auth_recoverSentSnack.
  ///
  /// In en, this message translates to:
  /// **'Password recovery instructions sent.'**
  String get auth_recoverSentSnack;

  /// No description provided for @auth_showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get auth_showPassword;

  /// No description provided for @auth_hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get auth_hidePassword;

  /// No description provided for @login_invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get login_invalidCredentials;

  /// No description provided for @login_network.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet.'**
  String get login_network;

  /// No description provided for @login_unknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get login_unknown;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settings_language;

  /// No description provided for @settings_lang_system.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get settings_lang_system;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
