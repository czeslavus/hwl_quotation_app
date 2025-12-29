import 'package:flutter/foundation.dart';
import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import 'package:wyceny/features/orders/ui/viewmodels/order_list_item.dart';

class OrdersListViewModel extends ChangeNotifier {
  // TopBar
  String customerName = "";
  String contractorName = "";

  // Dane / status
  bool loading = false;
  Object? error;

  // Paginacja
  int page = 1;
  int pageSize = 20;
  final List<int> pageSizeOptions = const [10, 20, 50, 100];
  bool isLastPage = false;

  // Filtry
  DateTime? dateFrom;
  DateTime? dateTo;
  int? originCountryId;
  int? destCountryId;
  String? status;
  final List<String> statusOptions = const ["new", "in_progress", "done", "canceled"];

  // Słowniki
  List<CountryDictionary> countries = const [];

  // Lista
  List<OrderListItem> items = const [];

  // ——— API ———
  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // TODO: fetch countries + first page
      countries = countries; // podmień na realny fetch
      await _loadPage();
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPage() async {
    // TODO: wywołanie repo z filtrami i paginacją
    // Poniżej mock:
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final mock = List.generate(pageSize, (i) {
      final idx = (page - 1) * pageSize + i + 1;
      return OrderListItem(
        id: "O$idx",
        orderNr: "ORD-${idx.toString().padLeft(5, '0')}",
        status: status ?? "new",
        createdAt: DateTime.now().subtract(Duration(days: idx % 30)),
        originCountry: CountryDictionary(countryId: 1, country: "Poland", countryCode: "PL"),
        originZip: "00-00${idx % 10}",
        destCountry: CountryDictionary(countryId: 2, country: "Germany", countryCode: "DE"),
        destZip: "10-10${idx % 10}",
        itemsCount: 1 + (idx % 4),
        weightChg: 123.0 + idx,
        total: 450.0 + idx * 3,
      );
    });
    items = mock;
    isLastPage = items.length < pageSize; // prosta heurystyka
  }

  void applyFilters({DateTime? from, DateTime? to, int? originId, int? destId, String? status}) {
    dateFrom = from;
    dateTo = to;
    originCountryId = originId;
    destCountryId = destId;
    this.status = status;
    page = 1;
    refresh();
  }

  Future<void> refresh() async {
    loading = true;
    notifyListeners();
    await _loadPage();
    loading = false;
    notifyListeners();
  }

  // Paginacja
  void nextPage() {
    if (isLastPage) return;
    page++;
    refresh();
  }

  void prevPage() {
    if (page == 1) return;
    page--;
    refresh();
  }

  void setPageSize(int v) {
    pageSize = v;
    page = 1;
    refresh();
  }

  // Akcje wiersza
  void view(String id) {
    // TODO: nawigacja do szczegółu
  }

  void edit(String id) {
    // TODO
  }

  Future<void> copy(String id) async {
    // TODO: skopiuj zamówienie
  }

  Future<void> cancel(String id) async {
    // TODO: anuluj zamówienie
  }

  // Pomocnicze
  String statusLabel(String? s) {
    switch (s) {
      case "new": return "Nowe";
      case "in_progress": return "W realizacji";
      case "done": return "Zrealizowane";
      case "canceled": return "Anulowane";
      default: return "—";
    }
  }

  String localizeCountryName(CountryDictionary? c, context) =>
      c == null ? "—" : CountryLocalizer.localize(c.country, context);
}
