import 'package:flutter/foundation.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';
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
        auth = auth ?? getIt<AuthState>();

  final QuotationsRepository _repo;
  final DictionariesRepository _dictRepo;
  final AuthState auth;

  Quotation? lastQuotation;

  // ================== ID / TRYB ==================
  int? quotationId; // null = nowe, != null = istniejące

  bool get isNewQuotation => quotationId == null;
  bool get canReject => quotationId != null;

  // ================== BLOKADA UI ==================
  bool quotationLoading = false;
  bool countriesLoading = false;
  bool packagingLoading = false;
  bool isSubmitting = false;
  bool hasAnyChangesStored = false;

  int quoteVersion = 0;

  bool get isUiLocked =>
      quotationLoading || countriesLoading || packagingLoading || isSubmitting;

  // ================== SŁOWNIKI ==================
  Object? countriesError;
  List<CountryDictionary> countries = const [];

  Object? packagingError;
  List<dynamic> packagingUnits = const [];

  // ================== HEADER ==================
  int? originCountryId;
  int? destinationCountryId;
  String originZip = '';
  String destinationZip = '';

  // ================== POZYCJE ==================
  final List<QuotationItem> items = <QuotationItem>[];

  void toggleAdr(int index) {
    /// zostawione do uzupełnienia
  }


  // ================== WYCENA ==================
  bool hasQuote = false;
  bool quoteIsFresh = false;
  bool quotePanelOpen = false;

  double get insurancePrice => lastQuotation?.insurancePrice ?? 0.0;
  double get additionalServicePrice => lastQuotation?.additionalServicePrice ?? 0.0;
  double get adrPrice => lastQuotation?.adrPrice ?? 0.0;
  double get shippingPrice => lastQuotation?.shippingPrice ?? 0.0;
  double get baf => lastQuotation?.baf ?? 0.0;
  double get taf => lastQuotation?.taf ?? 0.0;
  double get inflCorrection => lastQuotation?.inflCorrection ?? 0.0;

  double get totalPrice => lastQuotation?.totalPrice ?? 0.0;

  String? countryCodeForId(int? id) {
    if (id == null) return null;
    final c = countries.cast<CountryDictionary?>().firstWhere((x) => x?.countryId == id, orElse: () => null);
    return c?.countryCode;
  }

  // ================== INIT ==================
  Future<void> init({int? quotationId}) async {
    await _loadCountries();
    await _loadPackagingUnits();

    if (quotationId != null) {
      await loadQuotation(quotationId);
    } else if (items.isEmpty) {
      addEmptyItem(markDirty: false);
    }
  }

  // ================== LOAD ==================
  Future<void> loadQuotation(int id) async {
    quotationLoading = true;
    notifyListeners();

    try {
      final q = await _repo.getQuotation(id);
      quotationId = q.quotationId;

      _mapQuotation(q);
      quoteIsFresh = true;
      quotePanelOpen = false;
    } finally {
      quotationLoading = false;
      notifyListeners();
    }
  }

  void _mapQuotation(Quotation q) {
    lastQuotation = q;

    quotationId = q.quotationId;

    originCountryId = q.receiptCountryId;
    destinationCountryId = q.deliveryCountryId;

    originZip = q.receiptZipCode;
    destinationZip = q.deliveryZipCode;

    items
      ..clear()
      ..addAll(q.quotationPositions ?? const <QuotationItem>[]);
    if (items.isEmpty) {
      addEmptyItem(markDirty: false);
    }

    hasQuote = q.hasAnyPriceComponent;
  }

  Future<void> clearAllData() async {
    // Jeśli ekran jest w trakcie wyceny / ładowania, to nie czyścimy.
    if (isUiLocked) return;

    // 1) Nowe zlecenie (brak ID) => "pusty ekran"
    if (quotationId == null) {
      originCountryId = null;
      destinationCountryId = null;
      originZip = '';
      destinationZip = '';
      items.clear();
      addEmptyItem(markDirty: false);

      // reset wyceny i stanu
      lastQuotation = null;
      hasQuote = false;
      quoteIsFresh = false;
      quotePanelOpen = false;

      notifyListeners();

      return;
    }

    // 2) Istniejące zlecenie => przywróć z repo (stan serwerowy)
    final id = quotationId!;
    quotationLoading = true;
    notifyListeners();

    try {
      final q = await _repo.getQuotation(id);

      // Uwaga: q.quotationId powinno być takie samo, ale zostawiamy defensywnie:
      quotationId = q.quotationId ?? id;

      _mapQuotation(q);

      quoteIsFresh = true;
      quotePanelOpen = true;
    } finally {
      quotationLoading = false;
      notifyListeners();
    }
  }

  // ================== SŁOWNIKI ==================
  Future<void> _loadCountries() async {
    countriesLoading = true;
    notifyListeners();
    try {
      countries = _dictRepo.countries;
    } finally {
      countriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPackagingUnits() async {
    packagingLoading = true;
    notifyListeners();
    try {
      packagingUnits = List<dynamic>.from(_dictRepo.loadUnits as List);
    } finally {
      packagingLoading = false;
      notifyListeners();
    }
  }

  // ================== EDYCJA ==================
  void markDirty() {
    quoteIsFresh = false;
    notifyListeners();
  }

  void setOriginCountryId(int? v) {
    if (originCountryId == v) return;
    originCountryId = v;
    markDirty();
  }

  void setDestinationCountryId(int? v) {
    if (destinationCountryId == v) return;
    destinationCountryId = v;
    markDirty();
  }

  void setOriginZip(String v) {
    if (originZip == v) return;
    originZip = v;
    markDirty();
  }

  void setDestinationZip(String v) {
    if (destinationZip == v) return;
    destinationZip = v;
    markDirty();
  }

  void addEmptyItem({bool markDirty = true}) {
    items.add(const QuotationItem(
      quantity: 1,
      length: 0,
      width: 0,
      height: 0,
      weight: 0,
      adr: false,
    ));
    if (markDirty) {
      markDirty();
    } else {
      notifyListeners();
    }
  }

  void updateItem(int index, QuotationItem item) {
    if (index < 0 || index >= items.length) return;
    items[index] = item;
    markDirty();
  }

  void removeItemAt(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    markDirty();
  }

  // ================== WYCENA (CREATE / UPDATE) ==================
  Future<bool> requestQuote() async {
    if (isUiLocked) return false;

    isSubmitting = true;
    quotePanelOpen = true;
    notifyListeners();

    try {
      final model = QuotationPostModel(
        quotationId: quotationId,
        deliveryCountryId: destinationCountryId!,
        deliveryZipCode: destinationZip.trim(),
        receiptCountryId: originCountryId!,
        receiptZipCode: originZip.trim(),
        adr: items.any((i) => i.adr),
        userName: auth.user ?? 'unknown',
        quotationPositions:  List<QuotationItem>.from(items),
      );

      final Quotation q = quotationId == null
          ? await _repo.create(model)
          : await _repo.update(model);

      quotationId = q.quotationId;
      _mapQuotation(q);
      quoteIsFresh = true;
      quotePanelOpen = true;
      quoteVersion++;
      hasAnyChangesStored = true;
      return true;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
    return false;
  }

  // ================== GETTERY UI ==================
  bool get canRequestQuote => !isUiLocked && items.isNotEmpty && !quoteIsFresh;

  bool get canSubmitFinal =>
      quoteIsFresh && quotationId != null && !isUiLocked;
}
