import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';

abstract class OrdersRepository {
  Future<List<OrderModel>> getOrdersHistory();      // mockowana historia POSTów
  Future<List<Quotation>> getQuotationsConverted(); // wyceny, które poszły jako order
}
