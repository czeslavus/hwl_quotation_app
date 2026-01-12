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
  String get common_retry => 'Ponów';

  @override
  String get yes => 'tak';

  @override
  String get no => 'nie';

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

  @override
  String get quotation_title => 'Kalkulator';

  @override
  String get announcement_line =>
      'Ogłoszenia / informacje o świętach / ograniczeniach';

  @override
  String get overdue_info => 'Informacje o zaległych płatnościach';

  @override
  String get topbar_logout => 'Wyloguj';

  @override
  String topbar_customer(Object branch, Object name, Object number) {
    return '$name — $branch ($number)';
  }

  @override
  String get gen_quote_number => 'Nr wyceny';

  @override
  String get gen_origin_country => 'Kraj nadania';

  @override
  String get gen_origin_zip => 'Kod pocztowy nadania';

  @override
  String get gen_dest_country => 'Kraj dostawy';

  @override
  String get gen_dest_zip => 'Kod pocztowy dostawy';

  @override
  String get items_section => 'Pozycje zamówienia';

  @override
  String get item_qty => 'Ilość (szt.)';

  @override
  String get item_len_cm => 'Długość (cm)';

  @override
  String get item_wid_cm => 'Szerokość (cm)';

  @override
  String get item_hei_cm => 'Wysokość (cm)';

  @override
  String get item_w_unit => 'Waga 1 szt. (kg)';

  @override
  String get item_pack_weight => 'Waga opak. (kg)';

  @override
  String get item_pack_type => 'Typ opakowania';

  @override
  String get item_dangerous => 'Towar niebezpieczny (ADR)';

  @override
  String get item_delete_tt => 'Usuń pozycję';

  @override
  String get add_item => 'Dodaj pozycję';

  @override
  String get extra_section => 'Usługi dodatkowe';

  @override
  String get insurance_value_label => 'Wartość ubezpieczenia';

  @override
  String get additional_services_label => 'Usługi dodatkowe';

  @override
  String get extra_pre_advice => 'Awizacja';

  @override
  String get extra_insurance_value => 'Wartość towaru do ubezpieczenia (PLN)';

  @override
  String get pricing_section => 'Panel wyceny';

  @override
  String get fee_baf => 'Opłata paliwowa BAF';

  @override
  String get fee_myt => 'Opłata drogowa MYT';

  @override
  String get fee_infl => 'Korekta infl.';

  @override
  String get fee_recalc_weight => 'Waga przeliczeniowa (kg)';

  @override
  String get fee_freight => 'Cena fracht';

  @override
  String get fee_all_in => 'Cena all-in';

  @override
  String get fee_insurance => 'Ubezpieczenie';

  @override
  String get fee_adr => 'ADR';

  @override
  String get fee_service => 'Serwis';

  @override
  String get fee_pre_advice => 'Awizacja';

  @override
  String get fee_total => 'Suma';

  @override
  String get action_quote => 'Wycena';

  @override
  String get action_submit => 'Zatwierdź i prześlij zlecenie';

  @override
  String get action_clear => 'Wyczyść formularz';

  @override
  String get action_reject => 'Odrzuć';

  @override
  String get map_placeholder => 'MAPA (widget niezależny)';

  @override
  String get map_icon_tt => 'Mapa';

  @override
  String get quotations_title => 'Wyceny międzynarodowe';

  @override
  String get filter_date_from => 'Data od';

  @override
  String get filter_date_to => 'Data do';

  @override
  String get filter_apply => 'Zastosuj filtry';

  @override
  String get filter_clear => 'Wyczyść';

  @override
  String get list_empty => 'Brak wycen do wyświetlenia.';

  @override
  String error_generic(Object msg) {
    return 'Błąd: $msg';
  }

  @override
  String get col_qnr => 'Numer wyceny';

  @override
  String get col_order_nr => 'Nr zlecenia';

  @override
  String get col_status => 'Status';

  @override
  String get col_created => 'Data wyceny';

  @override
  String get col_valid_to => 'Data ważności';

  @override
  String get col_decision_date => 'Data akcept./odrzuc.';

  @override
  String get col_origin_country => 'Kraj nadania';

  @override
  String get col_origin_zip => 'Kod nadania';

  @override
  String get col_dest_country => 'Kraj dostawy';

  @override
  String get col_dest_zip => 'Kod dostawy';

  @override
  String get col_mp_sum => 'MP (suma)';

  @override
  String get col_weight => 'Waga';

  @override
  String get col_price => 'Cena';

  @override
  String get col_actions => 'Akcje';

  @override
  String get col_details => 'Detale';

  @override
  String get col_route => 'Z/Do';

  @override
  String get action_edit => 'Edytuj';

  @override
  String get action_copy => 'Kopiuj';

  @override
  String get action_new_quotation => 'Nowa wycena';

  @override
  String get action_open_order => 'Pokaż zamówienie';

  @override
  String get reason_optional => 'Powód (opcjonalnie)';

  @override
  String get cancel => 'Anuluj';

  @override
  String get ok => 'OK';

  @override
  String pagination_page(Object p) {
    return 'Strona $p';
  }

  @override
  String get pagination_page_size => 'Wierszy na stronę';

  @override
  String get orders_title => 'Zamówienia';

  @override
  String get action_new_order => 'Nowe zamówienie';

  @override
  String get action_view => 'Podgląd';

  @override
  String get action_cancel => 'Anuluj';

  @override
  String get col_items_count => 'Pozycje';

  @override
  String get order_title => 'Nowe zlecenie';

  @override
  String get section_sender => 'Nadawca';

  @override
  String get section_recipient => 'Odbiorca';

  @override
  String get field_name => 'Nazwa';

  @override
  String get field_city => 'Miasto';

  @override
  String get field_street => 'Ulica';

  @override
  String get field_phone => 'Telefon';

  @override
  String get items_title => 'Towar / paczki';

  @override
  String get label_qty => 'Ilość (szt)';

  @override
  String get label_pack_type => 'Typ opakowania';

  @override
  String get label_length_cm => 'Długość (cm)';

  @override
  String get label_width_cm => 'Szerokość (cm)';

  @override
  String get label_height_cm => 'Wysokość (cm)';

  @override
  String get label_weight_real_kg => 'Waga rzeczywista (kg)';

  @override
  String get label_item_cbm => 'CBM pozycji';

  @override
  String get services_title => 'Usługi dodatkowe';

  @override
  String get services_services => 'Serwisy (dodatkowe czynności)';

  @override
  String get services_pre_advice => 'Awizacja';

  @override
  String get services_cargo_insurance =>
      'Dodatkowe ubezpieczenie CARGO (wartość)';

  @override
  String get summary_cbm => 'CBM';

  @override
  String get summary_all_in => 'Suma (ALL-IN)';

  @override
  String get action_calculate => 'Przelicz';

  @override
  String get action_submit_order => 'Zatwierdź zlecenie';

  @override
  String get status_new => 'Nowe';

  @override
  String get status_in_progress => 'W realizacji';

  @override
  String get status_done => 'Zrealizowane';

  @override
  String get status_canceled => 'Anulowane';

  @override
  String get status_unknown => '—';

  @override
  String get confirm_clear_all =>
      'Usunąć wprowadzone dane wyceny (włączając w to wszystkie pozycje)?';

  @override
  String get submit_ok => 'Zapisane';

  @override
  String get submit_error => 'Błąd';

  @override
  String get items_empty_hint => 'Dodaj pozycję';

  @override
  String get item_cbm => 'CBM';

  @override
  String get item_lbm => 'LBM';

  @override
  String get item_ldm_cbm => 'LBM/CBM';

  @override
  String get item_long_weight => 'Long weight';

  @override
  String get sum_packages => 'Razem opakowań';

  @override
  String get sum_weight => 'Sumaryczna masa';

  @override
  String get sum_volume => 'Sumaryczna objętość';

  @override
  String get sum_long_weight => 'Total long weight';

  @override
  String get details => 'Pokaż szczegóły';

  @override
  String get no_details => 'Ukryj szczegóły';
}
