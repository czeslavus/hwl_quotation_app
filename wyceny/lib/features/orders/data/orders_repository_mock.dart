
import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/orders/domain/orders_repository.dart';
import 'package:wyceny/features/quotations/data/quotation_repository_mock.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';

class MockOrdersRepository implements OrdersRepository {
  final MockQuotationsRepository _pricingRepo;
  MockOrdersRepository(this._pricingRepo);

  @override
  Future<List<OrderModel>> getOrdersHistory() async => _pricingRepo.debugOrders();

  @override
  Future<List<Quotation>> getQuotationsConverted() async =>
      _pricingRepo.debugQuotations().where((p) => (p.orderNrSl ?? '').isNotEmpty).toList();
}
