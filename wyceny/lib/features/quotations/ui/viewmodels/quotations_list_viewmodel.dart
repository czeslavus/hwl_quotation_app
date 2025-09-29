import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';
import 'package:wyceny/features/quotations/domain/models/reject_model.dart';
import 'package:wyceny/features/quotations/domain/models/dictionaries/dicts.dart';
import 'package:wyceny/features/quotations/domain/quotations_repository.dart';

class QuotationsListViewModel extends ChangeNotifier {
  QuotationsListViewModel({
    QuotationsRepository? repo,
    AuthState? auth,
  })  : _repo = repo ?? getIt<QuotationsRepository>(),
        _auth = auth ?? getIt<AuthState>();

  final QuotationsRepository _repo;
  final AuthState _auth;

  // Topbar (zależne od AuthState)
  String get customerName => "${_auth.forename} ${_auth.surname}";
  String get contractorName => _auth.contractorName;

  // Filtry
  DateTime? dateFrom;
  DateTime? dateTo;
  int? originCountryId;
  int? destCountryId;

  // Słowniki
  List<Country> countries = const [];
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
      final data = await _repo.getCountries();
      countries = data;
      // domyślne wartości (jeśli puste)
      originCountryId ??= countries.firstWhere((c) => c.country == "Poland", orElse: () => data.first).id;
      destCountryId ??= countries.firstWhere((c) => c.country == "Germany", orElse: () => data.first).id;
    } catch (_) {/* brak fatal */}
  }

  Future<void> _loadStatuses() async {
    try {
      final dicts = await _repo.getStatuses();
      statuses = { for (final s in dicts) s.id!: (s.name ?? s.id.toString()) };
    } catch (_) {/* fallback na ID */}
  }

  Future<void> fetch() async {
    loading = true; error = null; notifyListeners();
    try {
      // Rozszerzony interfejs: opcjonalne filtry (możesz dodać w swojej implementacji repo)
      final result = await _repo.getArchive(
        page: page, pageSize: pageSize,
        dateFrom: dateFrom, dateTo: dateTo,
        originCountryId: originCountryId, destCountryId: destCountryId,
      );
      items = result;
      isLastPage = result.length < pageSize;
    } catch (e) {
      error = e;
    } finally {
      loading = false; notifyListeners();
    }
  }

  void setPageSize(int newSize) { pageSize = newSize; page = 1; fetch(); }
  void nextPage() { if (!isLastPage) { page += 1; fetch(); } }
  void prevPage() { if (page > 1) { page -= 1; fetch(); } }

  void applyFilters({DateTime? from, DateTime? to, int? originId, int? destId}) {
    dateFrom = from; dateTo = to; originCountryId = originId; destCountryId = destId;
    page = 1; fetch();
  }

  // Akcje na rekordzie
  Future<void> approve(int id) async {
    loading = true; notifyListeners();
    try { await _repo.approve(id); await fetch(); } finally { loading = false; notifyListeners(); }
  }

  Future<void> reject(int id, {String? reason}) async {
    loading = true; notifyListeners();
    try { await _repo.reject(RejectModel(quotationId: id, reason: reason ?? "None")); await fetch(); } finally { loading = false; notifyListeners(); }
  }

  Future<Quotation> copy(int id) => _repo.copy(id);

  // Pomocnicze
  String statusLabel(int? id) => (id == null) ? "-" : (statuses[id] ?? id.toString());

  String localizeCountryName(int? id, BuildContext context) {
    final c = countries.cast<Country?>().firstWhere((x) => x?.id == id, orElse: () => null);
    return CountryLocalizer.localize(c?.country, context);
  }
}