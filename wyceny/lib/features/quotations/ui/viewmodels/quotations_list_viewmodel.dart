import 'package:flutter/cupertino.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';
import 'package:wyceny/features/quotations/domain/models/reject_model.dart';
import 'package:wyceny/features/dictionaries/domain/models/models.dart';
import 'package:wyceny/features/quotations/domain/quotations_repository.dart';

class QuotationsListViewModel extends ChangeNotifier {
  QuotationsListViewModel({
    QuotationsRepository? repo,
    DictionariesRepository? dictRepo,
    AuthState? auth,
  })  : _repo = repo ?? getIt<QuotationsRepository>(),
        _dictRepo = dictRepo ?? getIt<DictionariesRepository>(),
        auth = auth ?? getIt<AuthState>();

  final QuotationsRepository _repo;
  final AuthState auth;
  final DictionariesRepository _dictRepo;

  // Filtry
  DateTime? dateFrom;
  DateTime? dateTo;

  /// Dest = kraj dostawy (deliveryCountryId w API)
  int? destCountryId;

  // Słowniki
  List<CountryDictionary> countries = const [];
  Map<int, String> statuses = const {};

  // Lista + paginacja
  List<Quotation> items = const [];
  int page = 1;
  int pageSize = 10;
  final List<int> pageSizeOptions = const [10, 25, 50, 100];
  bool isLastPage = false;

  // UI state
  bool loading = false;
  Object? error;

  Future<void> init() async {
    await Future.wait([_loadCountries(), _loadStatuses()]);
    await fetch();
  }

  Future<void> _loadCountries() async {
    try {
      final data = _dictRepo.countries;
      countries = data;

    } catch (_) {/* brak fatal */}
  }

  Future<void> _loadStatuses() async {
    try {
      final dicts = _dictRepo.statuses;
      statuses = {for (final s in dicts) s.statusId: (s.name ?? s.statusId.toString())};
    } catch (_) {/* fallback na ID */}
  }

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // Nadanie jest zawsze PL -> nie filtrujemy originCountryId
      final result = await _repo.getArchive(
        page: page,
        pageSize: pageSize,
        dateFrom: dateFrom,
        dateTo: dateTo,
        destCountryId: destCountryId,
      );

      items = result;
      isLastPage = result.length < pageSize;
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setPageSize(int newSize) {
    pageSize = newSize;
    page = 1;
    fetch();
  }

  void nextPage() {
    if (!isLastPage) {
      page += 1;
      fetch();
    }
  }

  void prevPage() {
    if (page > 1) {
      page -= 1;
      fetch();
    }
  }

  void applyFilters({
    DateTime? from,
    DateTime? to,
    int? destId,
  }) {
    dateFrom = from;
    dateTo = to;
    destCountryId = destId;
    page = 1;
    fetch();
  }

  // Akcje na rekordzie
  Future<void> approve(int quotationId) async {
    loading = true;
    notifyListeners();
    try {
      await _repo.approve(quotationId);
      await fetch();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Nowe API wymaga rejectCauseId.
  /// [rejectCause] jest opcjonalnym opisem (nullable).
  Future<void> reject(
      int quotationId, {
        int? rejectCauseId,
        String? rejectCause,
      }) async {
    loading = true;
    notifyListeners();
    try {
      await _repo.reject(
        RejectModel(
          quotationId: quotationId,
          rejectCauseId: rejectCauseId ?? 1,
          rejectCause: rejectCause,
        ),
      );
      await fetch();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Quotation> copy(int quotationId) => _repo.copy(quotationId);

  // ---- Helpery do tabeli ----

  String statusLabel(int? id) => (id == null) ? "-" : (statuses[id] ?? id.toString());

  String localizeCountryName(int? id, BuildContext context) {
    if (id == null) return "—";
    final c = countries.cast<CountryDictionary?>().firstWhere((x) => x?.countryId == id, orElse: () => null);
    return CountryLocalizer.localize(c?.country, context);
  }

  String countryCodeForId(int? id) {
    if (id == null) return "—";

    final c = countries.cast<CountryDictionary?>().firstWhere((x) => x?.countryId == id, orElse: () => null);
    final code = (c?.countryCode ?? "").trim();
    if (code.isNotEmpty) {
      return code;
    }
    final name = (c?.country ?? "").trim();
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();

    return "—";
  }
}
