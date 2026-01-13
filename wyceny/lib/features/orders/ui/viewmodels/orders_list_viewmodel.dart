import 'package:flutter/foundation.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';
import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/orders/domain/orders_repository.dart';
import 'package:wyceny/l10n/country_localizer.dart';

class OrdersListViewModel extends ChangeNotifier {
  OrdersListViewModel({
    OrdersRepository? repo,
    DictionariesRepository? dictRepo,
    AuthState? auth,
  })  : _repo = repo ?? getIt<OrdersRepository>(),
        _dictRepo = dictRepo ?? getIt<DictionariesRepository>(),
        auth = auth ?? getIt<AuthState>();

  final OrdersRepository _repo;
  final DictionariesRepository _dictRepo;
  final AuthState auth;

  bool loading = false;
  Object? error;

  // Paginacja
  int page = 1;
  int pageSize = 20;
  final List<int> pageSizeOptions = const [10, 20, 50, 100];
  bool isLastPage = false;

  // Filtry zgodne z API
  String? orderCustomerNr;
  DateTime? deliveryStartDate;
  DateTime? deliveryEndDate;
  DateTime? receiptStartDate;
  DateTime? receiptEndDate;
  String? statusNr;
  String? deliveryCountry;
  String? deliveryZipCode;
  String? receiptZipCode;

  final List<String> statusOptions = const ['NEW', 'IN_PROGRESS', 'DONE', 'CANCELED'];

  // Słowniki
  List<CountryDictionary> countries = const [];

  // Lista
  List<OrderModel> items = const [];

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      countries = _dictRepo.countries;
      await _loadPage();
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPage() async {
    final result = await _repo.getOrders(
      page: page,
      pageSize: pageSize,
      orderCustomerNr: orderCustomerNr,
      deliveryStartDate: deliveryStartDate,
      deliveryEndDate: deliveryEndDate,
      receiptStartDate: receiptStartDate,
      receiptEndDate: receiptEndDate,
      statusNr: statusNr,
      deliveryCountry: deliveryCountry,
      deliveryZipCode: deliveryZipCode,
      receiptZipCode: receiptZipCode,
    );
    items = result;
    isLastPage = result.length < pageSize;
  }

  void applyFilters({
    String? orderCustomerNr,
    DateTime? deliveryStart,
    DateTime? deliveryEnd,
    DateTime? receiptStart,
    DateTime? receiptEnd,
    String? status,
    String? deliveryCountry,
    String? deliveryZip,
    String? receiptZip,
  }) {
    this.orderCustomerNr = orderCustomerNr;
    deliveryStartDate = deliveryStart;
    deliveryEndDate = deliveryEnd;
    receiptStartDate = receiptStart;
    receiptEndDate = receiptEnd;
    statusNr = status;
    this.deliveryCountry = deliveryCountry;
    deliveryZipCode = deliveryZip;
    receiptZipCode = receiptZip;
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

  void view(String id) {}
  void edit(String id) {}
  Future<void> copy(String id) async {}
  Future<void> cancel(String id) async {
    await _repo.cancelOrder(id);
    await refresh();
  }

  String statusLabel(String? s) {
    switch (s) {
      case 'NEW':
        return 'Nowe';
      case 'IN_PROGRESS':
        return 'W realizacji';
      case 'DONE':
        return 'Zrealizowane';
      case 'CANCELED':
        return 'Anulowane';
      default:
        return '—';
    }
  }

  String localizeCountryName(String? countryCode, context) {
    if (countryCode == null || countryCode.trim().isEmpty) return '—';
    final c = countries.cast<CountryDictionary?>().firstWhere(
          (x) => x?.countryCode.toLowerCase() == countryCode.toLowerCase(),
      orElse: () => null,
    );
    return CountryLocalizer.localize(c?.country, context);
  }

  String? countryCodeForId(int? id) {
    if (id == null) return null;
    final c = countries.cast<CountryDictionary?>().firstWhere(
          (x) => x?.countryId == id,
      orElse: () => null,
    );
    return c?.countryCode;
  }
}
