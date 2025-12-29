import 'package:flutter/foundation.dart';
import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';

import 'package:wyceny/features/orders/ui/viewmodels/order_item.dart';

/// Szkielet ViewModelu do ekranu nowego zlecenia.
/// Podmień logikę cenową w _recalcPricing() pod swoje zasady.
class OrderViewModel extends ChangeNotifier {
  // ——— Kontekst klient/kontrahent (np. z sesji / auth) ———
  String customerName = "";
  String contractorName = "";

  // ——— Słowniki (kraje) ———
  bool countriesLoading = false;
  Object? countriesError;
  List<CountryDictionary> countries = const [];

  // ——— Dane NADAWCY ———
  int? originCountryId;
  String originZip = "";
  String senderName = "";
  String senderCity = "";
  String senderStreet = "";
  String senderPhone = "";

  // ——— Dane ODBIORCY ———
  int? destinationCountryId;
  String destZip = "";
  String recipientName = "";
  String recipientCity = "";
  String recipientStreet = "";
  String recipientPhone = "";

  // ——— Usługi/ubezpieczenie ———
  bool services = false;     // „Serwisy”
  bool preAdvice = false;    // „Awizacja”
  double insuranceValue = 0; // wartość cargo do ubezpieczenia

  // ——— Pozycje towarowe ———
  final List<OrderItem> items = [];

  // ——— Wyliczenia / podsumowanie ———
  double cbmTotal = 0;       // suma CBM
  double chargeableWeight = 0; // waga przeliczeniowa (kg)
  double freight = 0;        // fracht bazowy
  double adrFee = 0;
  double serviceFee = 0;
  double insuranceFee = 0;
  double totalPrice = 0;     // ALL-IN

  // ——— Public API ———

  /// Pierwsze pobrania (np. kraje).
  Future<void> init() async {
    countriesLoading = true;
    countriesError = null;
    notifyListeners();

    try {
      // TODO: podłącz realny fetch słowników (DI/repo).
      // Tymczasowo: pusta lista lub mock.
      countries = countries; // zostawiamy to jak jest
    } catch (e) {
      countriesError = e;
    } finally {
      countriesLoading = false;
      notifyListeners();
    }
  }

  void setOriginCountry(int? id) {
    originCountryId = id;
    notifyListeners();
  }

  void setDestinationCountry(int? id) {
    destinationCountryId = id;
    notifyListeners();
  }

  void addItem() {
    items.add(OrderItem.example());
    _recalcPricing();
  }

  void updateItem(int index, OrderItem it) {
    if (index < 0 || index >= items.length) return;
    items[index] = it;
    _recalcPricing();
  }

  void removeItem(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    _recalcPricing();
  }

  void clear() {
    originCountryId = null;
    destinationCountryId = null;
    originZip = destZip = "";
    senderName = senderCity = senderStreet = senderPhone = "";
    recipientName = recipientCity = recipientStreet = recipientPhone = "";

    services = false;
    preAdvice = false;
    insuranceValue = 0;

    items.clear();

    cbmTotal = 0;
    chargeableWeight = 0;
    freight = 0;
    adrFee = 0;
    serviceFee = 0;
    insuranceFee = 0;
    totalPrice = 0;

    notifyListeners();
  }

  /// Przelicz – możesz podmienić na wywołanie API kalkulatora.
  Future<void> calculate() async {
    // TODO: opcjonalnie validacja / call do API.
    _recalcPricing();
  }

  /// Zatwierdź zlecenie – wyślij na backend i obsłuż wynik.
  Future<void> submit() async {
    // TODO: walidacja + submit do backendu
  }

  // ——— Logika przeliczeń (przykładowa) ———

  void _recalcPricing() {
    // Suma CBM
    cbmTotal = items.fold<double>(0, (s, it) => s + it.cbm);

    // Waga przeliczeniowa (1 CBM = 167 kg – popularny mnożnik drogowy)
    final volumetricKg = cbmTotal * 167.0;
    final realKg = items.fold<double>(0, (s, it) => s + (it.weightKg ?? 0) * (it.qty ?? 0));
    chargeableWeight = realKg > volumetricKg ? realKg : volumetricKg;

    // Prosty cennik przykładowy (podmień na swój)
    final basePerKg = _baseRatePerKgForRelation(originCountryId, destinationCountryId);
    freight = chargeableWeight * basePerKg;

    // ADR – dopłata, jeśli którakolwiek pozycja ma ADR
    final hasAdr = items.any((it) => it.adr == true);
    adrFee = hasAdr ? 35.0 : 0.0;

    // Serwisy – ryczałt
    serviceFee = services ? 25.0 : 0.0;

    // Ubezpieczenie cargo: 0.15% wartości + min 10
    insuranceFee = (insuranceValue > 0) ? (insuranceValue * 0.0015).clamp(10.0, double.infinity) : 0.0;

    // Awizacja – przykładowo 5
    final preAdviceFee = preAdvice ? 5.0 : 0.0;

    totalPrice = freight + adrFee + serviceFee + insuranceFee + preAdviceFee;

    notifyListeners();
  }

  double _baseRatePerKgForRelation(int? fromId, int? toId) {
    // Przykład: inne stawki dla krajowych / międzynarodowych
    if (fromId == null || toId == null) return 0.0;
    final same = fromId == toId;
    return same ? 0.22 : 0.45; // PLN/kg (przykład)
  }
}
