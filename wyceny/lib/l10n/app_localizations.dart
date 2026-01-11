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

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

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

  /// No description provided for @quotation_title.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get quotation_title;

  /// No description provided for @announcement_line.
  ///
  /// In en, this message translates to:
  /// **'Announcements / info about public holidays / restrictions'**
  String get announcement_line;

  /// No description provided for @overdue_info.
  ///
  /// In en, this message translates to:
  /// **'Overdue payments information'**
  String get overdue_info;

  /// No description provided for @topbar_logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get topbar_logout;

  /// Top bar title with customer and contractor
  ///
  /// In en, this message translates to:
  /// **'{name} — {branch} ({number})'**
  String topbar_customer(Object branch, Object name, Object number);

  /// No description provided for @gen_quote_number.
  ///
  /// In en, this message translates to:
  /// **'Quotation number'**
  String get gen_quote_number;

  /// No description provided for @gen_origin_country.
  ///
  /// In en, this message translates to:
  /// **'Origin country'**
  String get gen_origin_country;

  /// No description provided for @gen_origin_zip.
  ///
  /// In en, this message translates to:
  /// **'Origin ZIP code'**
  String get gen_origin_zip;

  /// No description provided for @gen_dest_country.
  ///
  /// In en, this message translates to:
  /// **'Destination country'**
  String get gen_dest_country;

  /// No description provided for @gen_dest_zip.
  ///
  /// In en, this message translates to:
  /// **'Destination ZIP code'**
  String get gen_dest_zip;

  /// No description provided for @items_section.
  ///
  /// In en, this message translates to:
  /// **'Order items'**
  String get items_section;

  /// No description provided for @item_qty.
  ///
  /// In en, this message translates to:
  /// **'Quantity (pcs)'**
  String get item_qty;

  /// No description provided for @item_len_cm.
  ///
  /// In en, this message translates to:
  /// **'Length (cm)'**
  String get item_len_cm;

  /// No description provided for @item_wid_cm.
  ///
  /// In en, this message translates to:
  /// **'Width (cm)'**
  String get item_wid_cm;

  /// No description provided for @item_hei_cm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get item_hei_cm;

  /// No description provided for @item_w_unit.
  ///
  /// In en, this message translates to:
  /// **'Unit weight (kg)'**
  String get item_w_unit;

  /// No description provided for @item_pack_weight.
  ///
  /// In en, this message translates to:
  /// **'Packaging weight (kg)'**
  String get item_pack_weight;

  /// No description provided for @item_pack_type.
  ///
  /// In en, this message translates to:
  /// **'Package type'**
  String get item_pack_type;

  /// No description provided for @item_dangerous.
  ///
  /// In en, this message translates to:
  /// **'Dangerous goods (ADR)'**
  String get item_dangerous;

  /// No description provided for @item_delete_tt.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get item_delete_tt;

  /// No description provided for @add_item.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get add_item;

  /// No description provided for @extra_section.
  ///
  /// In en, this message translates to:
  /// **'Additional services'**
  String get extra_section;

  /// No description provided for @extra_pre_advice.
  ///
  /// In en, this message translates to:
  /// **'Pre-advice'**
  String get extra_pre_advice;

  /// No description provided for @extra_insurance_value.
  ///
  /// In en, this message translates to:
  /// **'Goods value for insurance (PLN)'**
  String get extra_insurance_value;

  /// No description provided for @pricing_section.
  ///
  /// In en, this message translates to:
  /// **'Pricing panel'**
  String get pricing_section;

  /// No description provided for @fee_baf.
  ///
  /// In en, this message translates to:
  /// **'Fuel surcharge (BAF)'**
  String get fee_baf;

  /// No description provided for @fee_myt.
  ///
  /// In en, this message translates to:
  /// **'Road toll (MYT)'**
  String get fee_myt;

  /// No description provided for @fee_infl.
  ///
  /// In en, this message translates to:
  /// **'Inflation adj.'**
  String get fee_infl;

  /// No description provided for @fee_recalc_weight.
  ///
  /// In en, this message translates to:
  /// **'Chargeable weight (kg)'**
  String get fee_recalc_weight;

  /// No description provided for @fee_freight.
  ///
  /// In en, this message translates to:
  /// **'Freight price'**
  String get fee_freight;

  /// No description provided for @fee_all_in.
  ///
  /// In en, this message translates to:
  /// **'All-in price'**
  String get fee_all_in;

  /// No description provided for @fee_insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get fee_insurance;

  /// No description provided for @fee_adr.
  ///
  /// In en, this message translates to:
  /// **'ADR'**
  String get fee_adr;

  /// No description provided for @fee_service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get fee_service;

  /// No description provided for @fee_pre_advice.
  ///
  /// In en, this message translates to:
  /// **'Pre-advice'**
  String get fee_pre_advice;

  /// No description provided for @fee_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get fee_total;

  /// No description provided for @action_quote.
  ///
  /// In en, this message translates to:
  /// **'QUOTE'**
  String get action_quote;

  /// No description provided for @action_submit.
  ///
  /// In en, this message translates to:
  /// **'APPROVE & SEND ORDER'**
  String get action_submit;

  /// No description provided for @action_clear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get action_clear;

  /// No description provided for @action_reject.
  ///
  /// In en, this message translates to:
  /// **'REJECT'**
  String get action_reject;

  /// No description provided for @map_placeholder.
  ///
  /// In en, this message translates to:
  /// **'MAP (independent widget)'**
  String get map_placeholder;

  /// No description provided for @map_icon_tt.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map_icon_tt;

  /// No description provided for @quotations_title.
  ///
  /// In en, this message translates to:
  /// **'International quotations'**
  String get quotations_title;

  /// No description provided for @filter_date_from.
  ///
  /// In en, this message translates to:
  /// **'Date from'**
  String get filter_date_from;

  /// No description provided for @filter_date_to.
  ///
  /// In en, this message translates to:
  /// **'Date to'**
  String get filter_date_to;

  /// No description provided for @filter_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filter_apply;

  /// No description provided for @filter_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filter_clear;

  /// No description provided for @list_empty.
  ///
  /// In en, this message translates to:
  /// **'No quotations found.'**
  String get list_empty;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String error_generic(Object msg);

  /// No description provided for @col_qnr.
  ///
  /// In en, this message translates to:
  /// **'Quotation no.'**
  String get col_qnr;

  /// No description provided for @col_order_nr.
  ///
  /// In en, this message translates to:
  /// **'Order no.'**
  String get col_order_nr;

  /// No description provided for @col_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get col_status;

  /// No description provided for @col_created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get col_created;

  /// No description provided for @col_valid_to.
  ///
  /// In en, this message translates to:
  /// **'Valid to'**
  String get col_valid_to;

  /// No description provided for @col_decision_date.
  ///
  /// In en, this message translates to:
  /// **'Accepted/Rejected'**
  String get col_decision_date;

  /// No description provided for @col_origin_country.
  ///
  /// In en, this message translates to:
  /// **'Origin country'**
  String get col_origin_country;

  /// No description provided for @col_origin_zip.
  ///
  /// In en, this message translates to:
  /// **'Origin ZIP'**
  String get col_origin_zip;

  /// No description provided for @col_dest_country.
  ///
  /// In en, this message translates to:
  /// **'Destination country'**
  String get col_dest_country;

  /// No description provided for @col_dest_zip.
  ///
  /// In en, this message translates to:
  /// **'Destination ZIP'**
  String get col_dest_zip;

  /// No description provided for @col_mp_sum.
  ///
  /// In en, this message translates to:
  /// **'MP (sum)'**
  String get col_mp_sum;

  /// No description provided for @col_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get col_weight;

  /// No description provided for @col_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get col_price;

  /// No description provided for @col_actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get col_actions;

  /// No description provided for @col_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get col_details;

  /// No description provided for @col_route.
  ///
  /// In en, this message translates to:
  /// **'From/To'**
  String get col_route;

  /// No description provided for @action_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get action_edit;

  /// No description provided for @action_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get action_copy;

  /// No description provided for @action_new_quotation.
  ///
  /// In en, this message translates to:
  /// **'New quotation'**
  String get action_new_quotation;

  /// No description provided for @action_open_order.
  ///
  /// In en, this message translates to:
  /// **'View shipment'**
  String get action_open_order;

  /// No description provided for @reason_optional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reason_optional;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @pagination_page.
  ///
  /// In en, this message translates to:
  /// **'Page {p}'**
  String pagination_page(Object p);

  /// No description provided for @pagination_page_size.
  ///
  /// In en, this message translates to:
  /// **'Rows per page'**
  String get pagination_page_size;

  /// No description provided for @orders_title.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders_title;

  /// No description provided for @action_new_order.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get action_new_order;

  /// No description provided for @action_view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get action_view;

  /// No description provided for @action_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get action_cancel;

  /// No description provided for @col_items_count.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get col_items_count;

  /// No description provided for @order_title.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get order_title;

  /// No description provided for @section_sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get section_sender;

  /// No description provided for @section_recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get section_recipient;

  /// No description provided for @field_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get field_name;

  /// No description provided for @field_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get field_city;

  /// No description provided for @field_street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get field_street;

  /// No description provided for @field_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get field_phone;

  /// No description provided for @items_title.
  ///
  /// In en, this message translates to:
  /// **'Goods / packages'**
  String get items_title;

  /// No description provided for @label_qty.
  ///
  /// In en, this message translates to:
  /// **'Qty (pcs)'**
  String get label_qty;

  /// No description provided for @label_pack_type.
  ///
  /// In en, this message translates to:
  /// **'Packaging type'**
  String get label_pack_type;

  /// No description provided for @label_length_cm.
  ///
  /// In en, this message translates to:
  /// **'Length (cm)'**
  String get label_length_cm;

  /// No description provided for @label_width_cm.
  ///
  /// In en, this message translates to:
  /// **'Width (cm)'**
  String get label_width_cm;

  /// No description provided for @label_height_cm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get label_height_cm;

  /// No description provided for @label_weight_real_kg.
  ///
  /// In en, this message translates to:
  /// **'Actual weight (kg)'**
  String get label_weight_real_kg;

  /// No description provided for @label_item_cbm.
  ///
  /// In en, this message translates to:
  /// **'Item CBM'**
  String get label_item_cbm;

  /// No description provided for @services_title.
  ///
  /// In en, this message translates to:
  /// **'Additional services'**
  String get services_title;

  /// No description provided for @services_services.
  ///
  /// In en, this message translates to:
  /// **'Services (extra handling)'**
  String get services_services;

  /// No description provided for @services_pre_advice.
  ///
  /// In en, this message translates to:
  /// **'Pre-advice'**
  String get services_pre_advice;

  /// No description provided for @services_cargo_insurance.
  ///
  /// In en, this message translates to:
  /// **'Additional CARGO insurance (value)'**
  String get services_cargo_insurance;

  /// No description provided for @summary_cbm.
  ///
  /// In en, this message translates to:
  /// **'CBM'**
  String get summary_cbm;

  /// No description provided for @summary_all_in.
  ///
  /// In en, this message translates to:
  /// **'Total (ALL-IN)'**
  String get summary_all_in;

  /// No description provided for @action_calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get action_calculate;

  /// No description provided for @action_submit_order.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM ORDER'**
  String get action_submit_order;

  /// No description provided for @status_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get status_new;

  /// No description provided for @status_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get status_in_progress;

  /// No description provided for @status_done.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get status_done;

  /// No description provided for @status_canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get status_canceled;

  /// No description provided for @status_unknown.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get status_unknown;

  /// No description provided for @confirm_clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear all quote data (icluding all items)?'**
  String get confirm_clear_all;

  /// No description provided for @submit_ok.
  ///
  /// In en, this message translates to:
  /// **'Submit ok.'**
  String get submit_ok;

  /// No description provided for @submit_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get submit_error;

  /// No description provided for @items_empty_hint.
  ///
  /// In en, this message translates to:
  /// **'Add position'**
  String get items_empty_hint;

  /// No description provided for @item_cbm.
  ///
  /// In en, this message translates to:
  /// **'CBM'**
  String get item_cbm;

  /// No description provided for @item_lbm.
  ///
  /// In en, this message translates to:
  /// **'LBM'**
  String get item_lbm;

  /// No description provided for @item_ldm_cbm.
  ///
  /// In en, this message translates to:
  /// **'LBM/CBM'**
  String get item_ldm_cbm;

  /// No description provided for @item_long_weight.
  ///
  /// In en, this message translates to:
  /// **'Long weight'**
  String get item_long_weight;

  /// No description provided for @sum_packages.
  ///
  /// In en, this message translates to:
  /// **'Total packages'**
  String get sum_packages;

  /// No description provided for @sum_weight.
  ///
  /// In en, this message translates to:
  /// **'Total weight'**
  String get sum_weight;

  /// No description provided for @sum_volume.
  ///
  /// In en, this message translates to:
  /// **'Total volume'**
  String get sum_volume;

  /// No description provided for @sum_long_weight.
  ///
  /// In en, this message translates to:
  /// **'Total long weight'**
  String get sum_long_weight;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get details;

  /// No description provided for @no_details.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get no_details;
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
