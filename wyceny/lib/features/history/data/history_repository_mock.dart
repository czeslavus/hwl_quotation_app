
import 'package:wyceny/features/history/domain/history_repository.dart';
import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/quotations/data/quotation_repository_mock.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';

class MockHistoryRepository implements HistoryRepository {
  final MockQuotationsRepository _pricingRepo;
  MockHistoryRepository(this._pricingRepo);

  @override
  Future<List<Quotation>> getQuotationsArchive({int page = 1, int pageSize = 10}) =>
      _pricingRepo.getArchive(page: page, pageSize: pageSize);

  @override
  Future<List<OrderModel>> getOrders() async => _pricingRepo.debugOrders();
}
