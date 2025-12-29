import 'package:flutter/foundation.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';
import 'package:wyceny/features/quotations/domain/models/quotation_item.dart';
import 'package:wyceny/features/quotations/domain/models/quotation_post_model.dart';
import 'package:wyceny/features/quotations/domain/quotations_repository.dart';

class QuotationViewModel extends ChangeNotifier {
  QuotationViewModel({
    QuotationsRepository? repo,
    DictionariesRepository? dictRepo,
    AuthState? auth,
  })  : _repo = repo ?? getIt<QuotationsRepository>(),
        _dictRepo = dictRepo ?? getIt<DictionariesRepository>(),
        _auth = auth ?? getIt<AuthState>();

  final QuotationsRepository _repo;
  final DictionariesRepository _dictRepo;
  final AuthState _auth;

  // ---------- Dictionaries ----------
  bool countriesLoading = false;
  Object? countriesError;
  List<CountryDictionary> countries = const [];

  bool packagingLoading = false;
  Object? packagingError;

  /// Słownik opakowań / loadUnitDictionary (typ celowo dynamic,
  /// bo model słownika może się różnić).
  List<dynamic> packagingUnits = const [];

  Future<void> init() async {
    await _loadCountries();
    await _loadPackagingUnits();
  }

  Future<void> _loadCountries() async {
    countriesLoading = true;
    countriesError = null;
    notifyListeners();
    try {
      final data = await _dictRepo.countries;
      countries = data;

      // sensowne domyślne (jeśli słownik je zawiera)
      originCountryId ??=
          countries.firstWhere((c) => c.country == "Poland", orElse: () => countries.first).countryId;
      destinationCountryId ??=
          countries.firstWhere((c) => c.country == "Germany", orElse: () => countries.first).countryId;
    } catch (e) {
      countriesError = e;
    } finally {
      countriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPackagingUnits() async {
    packagingLoading = true;
    packagingError = null;
    notifyListeners();
    try {
      // Zgodnie z Twoją informacją: słownik opakowań = loadUnitDictionary
      final data = await _dictRepo.loadUnits;
      packagingUnits = List<dynamic>.from(data as List);
    } catch (e) {
      packagingError = e;
    } finally {
      packagingLoading = false;
      notifyListeners();
    }
  }

  // ---------- Header / Quotation fields ----------
  int? originCountryId;
  int? destinationCountryId;

  String originZip = '';
  String destinationZip = '';

  void setOriginCountryId(int? value) {
    if (originCountryId == value) return;
    originCountryId = value;
    markDirty();
  }

  void setDestinationCountryId(int? value) {
    if (destinationCountryId == value) return;
    destinationCountryId = value;
    markDirty();
  }

  void setOriginZip(String value) {
    if (originZip == value) return;
    originZip = value;
    markDirty();
  }

  void setDestinationZip(String value) {
    if (destinationZip == value) return;
    destinationZip = value;
    markDirty();
  }

  // ---------- Items ----------
  final List<QuotationItem> items = <QuotationItem>[];

  void addEmptyItem() {
    items.add(const QuotationItem(
      quantity: 1,
      length: 0,
      width: 0,
      height: 0,
      weight: 0,
      adr: false,
    ));
    markDirty();
  }

  void removeItemAt(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    markDirty();
  }

  void clearAllData() {
    originCountryId = null;
    destinationCountryId = null;
    originZip = '';
    destinationZip = '';
    items.clear();
    resetQuote();
    notifyListeners();
  }

  // --- Per-item updates (edytowalne pola) ---
  void updateItem(int index, QuotationItem item) {
    if (index < 0 || index >= items.length) return;
    items[index] = item;
    markDirty();
  }

  void toggleAdr(int index) {
    if (index < 0 || index >= items.length) return;
    final current = items[index];
    items[index] = current.copyWith(adr: !current.adr);
    markDirty();
  }

  // ---------- Sums (auto) ----------
  int get sumPackages => items.fold<int>(0, (acc, i) => acc + i.quantity);

  double get sumWeight => items.fold<double>(
    0,
        (acc, i) => acc + (i.weight.toDouble() * i.quantity.toDouble()),
  );

  /// Objętość liczona jako iloczyn length*width*height * quantity
  /// (jednostka zależy od danych wejściowych; UI może konwertować na m3).
  double get sumVolume => items.fold<double>(
    0,
        (acc, i) =>
    acc + (i.quantity.toDouble() * i.length.toDouble() * i.width.toDouble() * i.height.toDouble()),
  );

  double get sumLongWeight => items.fold<double>(
    0,
        (acc, i) => acc + (i.quantity.toDouble() * (i.longWeight ?? 0.0)),
  );

  // ---------- Quote state ----------
  bool isQuoting = false;

  /// Flaga: wycena jest aktualna (po kliknięciu "Wycena")
  bool hasQuote = false;

  /// Cena sumaryczna (placeholder – docelowo z API)
  double? totalPrice;

  /// Szczegóły (placeholder – lista pozycji wyceny)
  List<Map<String, dynamic>> quoteLines = const [];

  bool get canQuote {
    final headerOk = (originCountryId != null) &&
        (destinationCountryId != null) &&
        originZip.trim().isNotEmpty &&
        destinationZip.trim().isNotEmpty;
    return headerOk && items.isNotEmpty && !isQuoting;
  }

  String get customerName => "Jan Kowalski";

  String get contractorName => "Ubu the King";

  /// Wołaj zawsze gdy zmieni się cokolwiek w quotation lub items.
  void markDirty() {
    resetQuote();
    notifyListeners();
  }

  void resetQuote() {
    hasQuote = false;
    totalPrice = null;
    quoteLines = const [];
    isQuoting = false;
  }

  /// Klik "Wycena" – na razie kalkulator placeholder.
  /// Docelowo tu podepniemy request do API.
  Future<void> calculateQuote() async {
    if (!canQuote) return;

    isQuoting = true;
    notifyListeners();

    try {
      // Placeholder: prosta kalkulacja żeby UI działało od razu
      // (np. baza + masa + longWeight + ADR fee)
      final base = 50.0;
      final weightPart = 0.35 * sumWeight;
      final longPart = 0.20 * sumLongWeight;
      final adrFee = items.any((i) => i.adr) ? 120.0 : 0.0;

      totalPrice = base + weightPart + longPart + adrFee;

      quoteLines = items.asMap().entries.map((e) {
        final idx = e.key;
        final it = e.value;
        final line = (it.quantity * it.weight).toDouble() * 0.35 +
            (it.quantity.toDouble() * (it.longWeight ?? 0.0)) * 0.20 +
            (it.adr ? 120.0 / items.length : 0.0);
        return <String, dynamic>{
          'index': idx + 1,
          'price': line,
          'adr': it.adr,
          'qty': it.quantity,
        };
      }).toList(growable: false);

      hasQuote = true;
    } finally {
      isQuoting = false;
      notifyListeners();
    }
  }

  // ---------- Submit (POST) ----------
  Future<void> submitOrder() async {
    // Wymaganie: "Zatwierdź" ma przygotować POST z quotation_post_model
    // i spróbować wypełnić wszystkie pola.
    if (destinationCountryId == null) {
      throw StateError('Brak kraju dostawy (destinationCountryId).');
    }
    if (originZip.trim().isEmpty || destinationZip.trim().isEmpty) {
      throw StateError('Brak kodów pocztowych.');
    }
    if (items.isEmpty) {
      throw StateError('Brak pozycji.');
    }

    final model = QuotationPostModel(
      // required wg modelu:
      deliveryCountryId: destinationCountryId!,
      deliveryZipCode: destinationZip.trim(),
      receiptZipCode: originZip.trim(),

      // reszta (opcjonalne / jeśli backend przyjmuje):
      adr: items.any((i) => i.adr),
      userName: "none", // jeśli w AuthState nazywa się inaczej – podmienimy
      quotationPositions: items,
    );

    await _repo.create(model);
  }
}
