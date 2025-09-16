
import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';

abstract class HistoryRepository {
  Future<List<Quotation>> getQuotationsArchive({int page = 1, int pageSize = 10});
  Future<List<OrderModel>> getOrders();
}
