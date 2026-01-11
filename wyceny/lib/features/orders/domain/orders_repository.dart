import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';

abstract class OrdersRepository {
  Future<List<OrderModel>> getOrders({
    int page,
    int pageSize,
    String? orderCustomerNr,
    DateTime? deliveryStartDate,
    DateTime? deliveryEndDate,
    DateTime? receiptStartDate,
    DateTime? receiptEndDate,
    String? statusNr,
    String? deliveryCountry,
    String? deliveryZipCode,
    String? receiptZipCode,
  });
  Future<List<OrderModel>> getOrdersHistory();
  Future<List<Quotation>> getQuotationsConverted();
}
