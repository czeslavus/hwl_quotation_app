import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/quotations/domain/models/dictionaries/dicts.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';
import 'package:wyceny/features/quotations/domain/models/quotation_post_model.dart';
import 'package:wyceny/features/quotations/domain/models/reject_model.dart';

abstract class QuotationsRepository {
  Future<Quotation> getQuotation(int id);
  Future<List<Quotation>> getArchive({
    int page = 1,
    int pageSize = 10,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? originCountryId,
    int? destCountryId
  });
  Future<Quotation> create(QuotationPostModel model);
  Future<Quotation> update(QuotationPostModel model);

  // Słowniki
  Future<List<Country>> getCountries();
  Future<List<Addition>> getAdditions();
  Future<List<ServiceDict>> getServices();
  Future<List<StatusDict>> getStatuses();

  // Akcje na wycenie
  Future<Quotation> copy(int id);
  Future<Quotation> approve(int id);
  Future<Quotation> reject(RejectModel model);

  // Konwersja do zamówienia
  Future<OrderModel> buildOrderFromQuotation(int id);
  Future<String> sendOrder(OrderModel model);
}
