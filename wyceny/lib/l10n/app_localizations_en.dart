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
  String get common_retry => 'Retry';

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

  @override
  String get quotation_title => 'Calculator';

  @override
  String get announcement_line =>
      'Announcements / info about public holidays / restrictions';

  @override
  String get overdue_info => 'Overdue payments information';

  @override
  String get topbar_logout => 'Log out';

  @override
  String topbar_customer(Object contractor, Object name) {
    return '$name — $contractor';
  }

  @override
  String get gen_quote_number => 'Quotation number';

  @override
  String get gen_origin_country => 'Origin country';

  @override
  String get gen_origin_zip => 'Origin ZIP code';

  @override
  String get gen_dest_country => 'Destination country';

  @override
  String get gen_dest_zip => 'Destination ZIP code';

  @override
  String get items_section => 'Order items';

  @override
  String get item_qty => 'Quantity (pcs)';

  @override
  String get item_len_cm => 'Length (cm)';

  @override
  String get item_wid_cm => 'Width (cm)';

  @override
  String get item_hei_cm => 'Height (cm)';

  @override
  String get item_w_unit => 'Unit weight (kg)';

  @override
  String get item_pack_type => 'Package type';

  @override
  String get item_dangerous => 'Dangerous goods (ADR)';

  @override
  String get item_delete_tt => 'Remove item';

  @override
  String get add_item => 'Add item';

  @override
  String get extra_section => 'Additional services';

  @override
  String get extra_pre_advice => 'Pre-advice';

  @override
  String get extra_insurance_value => 'Goods value for insurance (PLN)';

  @override
  String get pricing_section => 'Pricing panel';

  @override
  String get fee_baf => 'Fuel surcharge (BAF)';

  @override
  String get fee_myt => 'Road toll (MYT)';

  @override
  String get fee_infl => 'Inflation adj.';

  @override
  String get fee_recalc_weight => 'Chargeable weight (kg)';

  @override
  String get fee_freight => 'Freight price';

  @override
  String get fee_all_in => 'All-in price';

  @override
  String get fee_insurance => 'Insurance';

  @override
  String get fee_adr => 'ADR';

  @override
  String get fee_service => 'Service';

  @override
  String get fee_pre_advice => 'Pre-advice';

  @override
  String get fee_total => 'Total';

  @override
  String get action_quote => 'QUOTE';

  @override
  String get action_submit => 'APPROVE & SEND ORDER';

  @override
  String get action_clear => 'CLEAR';

  @override
  String get action_reject => 'REJECT';

  @override
  String get map_placeholder => 'MAP (independent widget)';

  @override
  String get map_icon_tt => 'Map';

  @override
  String get quotations_title => 'International quotations';

  @override
  String get filter_date_from => 'Date from';

  @override
  String get filter_date_to => 'Date to';

  @override
  String get filter_apply => 'Apply filters';

  @override
  String get filter_clear => 'Clear';

  @override
  String get list_empty => 'No quotations found.';

  @override
  String error_generic(Object msg) {
    return 'Error: $msg';
  }

  @override
  String get col_qnr => 'Quotation no.';

  @override
  String get col_order_nr => 'Order no.';

  @override
  String get col_status => 'Status';

  @override
  String get col_created => 'Created';

  @override
  String get col_valid_to => 'Valid to';

  @override
  String get col_decision_date => 'Accepted/Rejected';

  @override
  String get col_origin_country => 'Origin country';

  @override
  String get col_origin_zip => 'Origin ZIP';

  @override
  String get col_dest_country => 'Destination country';

  @override
  String get col_dest_zip => 'Destination ZIP';

  @override
  String get col_mp_sum => 'MP (sum)';

  @override
  String get col_weight => 'Weight';

  @override
  String get col_price => 'Price';

  @override
  String get col_actions => 'Actions';

  @override
  String get action_edit => 'Edit';

  @override
  String get action_copy => 'Copy';

  @override
  String get action_new_quotation => 'New quotation';

  @override
  String get reason_optional => 'Reason (optional)';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String pagination_page(Object p) {
    return 'Page $p';
  }

  @override
  String get pagination_page_size => 'Rows per page';

  @override
  String get orders_title => 'Orders';

  @override
  String get action_new_order => 'New order';

  @override
  String get action_view => 'View';

  @override
  String get action_cancel => 'Cancel';

  @override
  String get col_items_count => 'Items';

  @override
  String get order_title => 'New order';

  @override
  String get section_sender => 'Sender';

  @override
  String get section_recipient => 'Recipient';

  @override
  String get field_name => 'Name';

  @override
  String get field_city => 'City';

  @override
  String get field_street => 'Street';

  @override
  String get field_phone => 'Phone';

  @override
  String get items_title => 'Goods / packages';

  @override
  String get label_qty => 'Qty (pcs)';

  @override
  String get label_pack_type => 'Packaging type';

  @override
  String get label_length_cm => 'Length (cm)';

  @override
  String get label_width_cm => 'Width (cm)';

  @override
  String get label_height_cm => 'Height (cm)';

  @override
  String get label_weight_real_kg => 'Actual weight (kg)';

  @override
  String get label_item_cbm => 'Item CBM';

  @override
  String get services_title => 'Additional services';

  @override
  String get services_services => 'Services (extra handling)';

  @override
  String get services_pre_advice => 'Pre-advice';

  @override
  String get services_cargo_insurance => 'Additional CARGO insurance (value)';

  @override
  String get summary_cbm => 'CBM';

  @override
  String get summary_all_in => 'Total (ALL-IN)';

  @override
  String get action_calculate => 'Calculate';

  @override
  String get action_submit_order => 'CONFIRM ORDER';

  @override
  String get status_new => 'New';

  @override
  String get status_in_progress => 'In progress';

  @override
  String get status_done => 'Completed';

  @override
  String get status_canceled => 'Canceled';

  @override
  String get status_unknown => '—';
}
