import 'package:wyceny/features/orders/domain/models/order_model.dart';
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
    int? destCountryId,
    int? statusId,
  });
  Future<Quotation> create(QuotationPostModel model);
  Future<Quotation> update(QuotationPostModel model);

  // Akcje na wycenie
  Future<Quotation> copy(int id);
  Future<Quotation> approve(int id);
  Future<Quotation> reject(RejectModel model);
  Future<void> delete(int id);

  // Konwersja do zamówienia
  Future<OrderModel> buildOrderFromQuotation(int id);
  Future<String> sendOrder(OrderModel model);
}
