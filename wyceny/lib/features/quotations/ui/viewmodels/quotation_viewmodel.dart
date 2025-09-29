import 'package:flutter/foundation.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/quotations/domain/quotations_repository.dart';
import 'package:wyceny/features/quotations/domain/models/dictionaries/dicts.dart';


class QuotationItem {
  int quantity;
  double length;
  double width;
  double height;
  double weight;
  String packageType;
  bool dangerous;

  QuotationItem({
    this.quantity = 1,
    this.length = 0,
    this.width = 0,
    this.height = 0,
    this.weight = 0,
    this.packageType = "Paleta",
    this.dangerous = false,
  });
}

class QuotationViewModel extends ChangeNotifier {

  QuotationViewModel({QuotationsRepository? repo, AuthState? auth})
      : _repo = repo ?? getIt<QuotationsRepository>(), _auth = auth ?? getIt<AuthState>();

  final QuotationsRepository _repo;
  final AuthState _auth;


  // topbar – normalnie wypełnisz z AuthService
  String get customerName => "${_auth.forename} ${_auth.surname}";
  String get contractorName => _auth.contractorName;

  // słowniki
  List<Country> countries = const [];
  bool countriesLoading = false;
  Object? countriesError;

  // wybrane kraje przez ID
  int? originCountryId;
  int? destinationCountryId;


  // dane ogólne
  String quotationNumber = "";
  String originCountry = "Polska";
  String originZip = "";
  String destinationCountry = "Niemcy";
  String destinationZip = "";

  // pozycje
  final List<QuotationItem> items = [QuotationItem()];

  // usługi dodatkowe
  bool preAdvice = false;
  double insuranceValue = 0;

  // wyniki
  double baf = 0, myt = 0, inflation = 0;
  double recalculatedWeight = 0;
  double freightPrice = 0;
  double allInPrice = 0;
  double insuranceFee = 0, adrFee = 0, serviceFee = 0, preAdviceFee = 0, total = 0;

  Future<void> init() async {
    await _loadCountries();
  }

  Future<void> _loadCountries() async {
    countriesLoading = true;
    countriesError = null;
    notifyListeners();
    try {
      final data = await _repo.getCountries();
      countries = data;
      // domyślne wybory, jeśli dostępne
      originCountryId ??= countries.firstWhere((c) => c.country == "Poland", orElse: () => countries.first).id;
      destinationCountryId ??= countries.firstWhere((c) => c.country == "Germany", orElse: () => countries.first).id;
    } catch (e) {
      countriesError = e;
    } finally {
      countriesLoading = false;
      notifyListeners();
    }
  }

  void setOriginCountry(int? id) { originCountryId = id; notifyListeners(); }
  void setDestinationCountry(int? id) { destinationCountryId = id; notifyListeners(); }

  // akcje
  void addItem() { items.add(QuotationItem()); notifyListeners(); }
  void removeItem(int index) { if (items.length > 1) { items.removeAt(index); notifyListeners(); } }
  void updateItem(int i, QuotationItem it) { items[i] = it; notifyListeners(); }

  void clear() {
    quotationNumber = "";
    originCountry = "Polska"; originZip = "";
    destinationCountry = "Niemcy"; destinationZip = "";
    items..clear()..add(QuotationItem());
    preAdvice = false; insuranceValue = 0;
    _resetCalc(); notifyListeners();
  }

  void _resetCalc() {
    baf = myt = inflation = 0;
    recalculatedWeight = freightPrice = allInPrice = 0;
    insuranceFee = adrFee = serviceFee = preAdviceFee = total = 0;
  }

  void calculate() {
    // PRZYKŁADOWA, PROSTA LOGIKA – podmień na prawdziwe reguły
    final volWeight = items.fold<double>(0, (sum, it) =>
    sum + ((it.length * it.width * it.height) / 6000.0) * it.quantity);
    final actWeight = items.fold<double>(0, (sum, it) => sum + it.weight * it.quantity);

    recalculatedWeight = (actWeight > volWeight ? actWeight : volWeight);

    freightPrice = 3.8 * recalculatedWeight; // zł/kg
    baf = 0.222 * freightPrice;
    myt = 0.0913 * freightPrice;
    inflation = 0.074 * freightPrice;

    adrFee = items.any((i) => i.dangerous) ? 120 : 0;
    preAdviceFee = preAdvice ? 35 : 0;
    insuranceFee = insuranceValue > 0 ? (0.002 * insuranceValue).clamp(10, 5000) : 0;
    serviceFee = 25;

    allInPrice = freightPrice + baf + myt + inflation;
    total = allInPrice + adrFee + preAdviceFee + insuranceFee + serviceFee;

    notifyListeners();
  }
}
