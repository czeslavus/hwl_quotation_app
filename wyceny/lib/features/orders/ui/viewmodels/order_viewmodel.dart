import 'package:flutter/foundation.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';
import 'package:wyceny/features/orders/ui/viewmodels/order_item.dart';

class OrderViewModel extends ChangeNotifier {
  OrderViewModel({
    DictionariesRepository? dictRepo,
    AuthState? auth,
  })  : _dictRepo = dictRepo ?? getIt<DictionariesRepository>(),
        auth = auth ?? getIt<AuthState>();

  final DictionariesRepository _dictRepo;
  final AuthState auth;

  bool countriesLoading = false;
  Object? countriesError;
  List<CountryDictionary> countries = const [];

  int? receiptCountryId;
  int? deliveryCountryId;
  String receiptZipCode = '';
  String deliveryZipCode = '';
  String receiptName = '';
  String receiptCity = '';
  String receiptStreet = '';
  String receiptPhone = '';
  String deliveryName = '';
  String deliveryCity = '';
  String deliveryStreet = '';
  String deliveryPhone = '';

  DateTime? receiptDateBegin;
  DateTime? receiptDateEnd;
  DateTime? deliveryDateBegin;
  DateTime? deliveryDateEnd;

  String? orderCustomerNr;
  double orderValue = 0;
  String? notificationEmail;
  String? notificationSms;

  bool services = false;
  bool preAdvice = false;
  double insuranceValue = 0;

  final List<OrderItem> items = [];

  double cbmTotal = 0;
  double chargeableWeight = 0;
  double freight = 0;
  double adrFee = 0;
  double serviceFee = 0;
  double insuranceFee = 0;
  double totalPrice = 0;

  Future<void> init() async {
    countriesLoading = true;
    countriesError = null;
    notifyListeners();

    try {
      countries = _dictRepo.countries;
    } catch (e) {
      countriesError = e;
    } finally {
      countriesLoading = false;
      notifyListeners();
    }
  }

  void setReceiptCountryId(int? id) {
    receiptCountryId = id;
    notifyListeners();
  }

  void setDeliveryCountryId(int? id) {
    deliveryCountryId = id;
    notifyListeners();
  }

  void setReceiptZip(String value) {
    receiptZipCode = value;
    notifyListeners();
  }

  void setDeliveryZip(String value) {
    deliveryZipCode = value;
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
    receiptCountryId = null;
    deliveryCountryId = null;
    receiptZipCode = '';
    deliveryZipCode = '';
    receiptName = '';
    receiptCity = '';
    receiptStreet = '';
    receiptPhone = '';
    deliveryName = '';
    deliveryCity = '';
    deliveryStreet = '';
    deliveryPhone = '';
    receiptDateBegin = null;
    receiptDateEnd = null;
    deliveryDateBegin = null;
    deliveryDateEnd = null;
    orderCustomerNr = null;
    orderValue = 0;
    notificationEmail = null;
    notificationSms = null;
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

  Future<void> calculate() async {
    _recalcPricing();
  }

  Future<void> submit() async {
    // TODO: walidacja + submit do backendu
  }

  String? countryCodeForId(int? id) {
    if (id == null) return null;
    final c = countries.cast<CountryDictionary?>().firstWhere((x) => x?.countryId == id, orElse: () => null);
    return c?.countryCode;
  }

  void _recalcPricing() {
    cbmTotal = items.fold<double>(0, (s, it) => s + it.cbm);

    final volumetricKg = cbmTotal * 167.0;
    final realKg = items.fold<double>(0, (s, it) => s + (it.weightKg ?? 0) * (it.qty ?? 0));
    chargeableWeight = realKg > volumetricKg ? realKg : volumetricKg;

    final basePerKg = _baseRatePerKgForRelation(receiptCountryId, deliveryCountryId);
    freight = chargeableWeight * basePerKg;

    final hasAdr = items.any((it) => it.adr == true);
    adrFee = hasAdr ? 35.0 : 0.0;

    serviceFee = services ? 25.0 : 0.0;

    insuranceFee = (insuranceValue > 0)
        ? (insuranceValue * 0.0015).clamp(10.0, double.infinity)
        : 0.0;

    final preAdviceFee = preAdvice ? 5.0 : 0.0;

    totalPrice = freight + adrFee + serviceFee + insuranceFee + preAdviceFee;

    notifyListeners();
  }

  double _baseRatePerKgForRelation(int? fromId, int? toId) {
    if (fromId == null || toId == null) return 0.0;
    final same = fromId == toId;
    return same ? 0.22 : 0.45;
  }
}
