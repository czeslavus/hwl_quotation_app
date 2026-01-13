import 'dart:math';

import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/orders/domain/orders_repository.dart';
import 'package:wyceny/features/quotations/data/quotation_repository_mock.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';

class MockOrdersRepository implements OrdersRepository {
  MockOrdersRepository(this._pricingRepo) {
    _seed();
  }

  final MockQuotationsRepository _pricingRepo;
  final List<OrderModel> _orders = [];

  void _seed() {
    if (_orders.isNotEmpty) return;

    final now = DateTime.now();
    final rng = Random(1);
    final statuses = ['NEW', 'IN_PROGRESS', 'DONE', 'CANCELED'];

    final countries = [
      const AddressModel(name: 'Poland', city: 'Warszawa', street: 'Jasna 1', zipCode: '00-001', country: 'PL'),
      const AddressModel(name: 'Germany', city: 'Berlin', street: 'Unter 2', zipCode: '10115', country: 'DE'),
      const AddressModel(name: 'Czechia', city: 'Prague', street: 'Main 3', zipCode: '11000', country: 'CZ'),
    ];

    for (var i = 0; i < 45; i++) {
      final baseReceipt = countries[i % countries.length];
      final baseDelivery = countries[(i + 1) % countries.length];
      final receipt = AddressModel(
        name: baseReceipt.name,
        city: baseReceipt.city,
        street: baseReceipt.street,
        zipCode: '${baseReceipt.zipCode.substring(0, 3)}${(i % 9) + 1}',
        country: baseReceipt.country,
        phoneNr: baseReceipt.phoneNr,
      );
      final delivery = AddressModel(
        name: baseDelivery.name,
        city: baseDelivery.city,
        street: baseDelivery.street,
        zipCode: '${baseDelivery.zipCode.substring(0, 3)}${(i % 7) + 1}',
        country: baseDelivery.country,
        phoneNr: baseDelivery.phoneNr,
      );
      final receiptDate = now.subtract(Duration(days: 30 - i));
      final deliveryDate = receiptDate.add(Duration(days: 2 + (i % 4)));

      _orders.add(
        OrderModel(
          quotationId: i + 1000,
          receiptPoint: receipt,
          deliveryPoint: delivery,
          loads: [
            LoadModel(
              weight: 80 + rng.nextInt(120).toDouble(),
              volume: 1.0 + rng.nextDouble() * 2,
              length: 120,
              width: 80,
              height: 80,
              unitType: 'PAL',
              unitQuantity: 1 + (i % 3),
            ),
          ],
          receiptDateBegin: receiptDate,
          receiptDateEnd: receiptDate.add(const Duration(hours: 4)),
          deliveryDateBegin: deliveryDate,
          deliveryDateEnd: deliveryDate.add(const Duration(hours: 6)),
          orderCustomerNr: 'CUST-${10000 + i}',
          orderValue: 1200 + i * 37.5,
          orderValueCurrency: 'PLN',
          notificationEmail: 'orders+$i@example.com',
          notificationSms: '+481234567${i.toString().padLeft(2, '0')}',
          instructionCodes: const [
            InstructionCodeModel(instructionCodeNr: 'POD'),
          ],
          orderId: i + 500,
          orderNr: 'ORD-${(i + 1).toString().padLeft(5, '0')}',
          stageTtNr: 'ST-${i + 1}',
          status: statuses[i % statuses.length],
          errors: const [],
        ),
      );
    }
  }

  @override
  Future<List<OrderModel>> getOrders({
    int page = 1,
    int pageSize = 10,
    String? orderCustomerNr,
    DateTime? deliveryStartDate,
    DateTime? deliveryEndDate,
    DateTime? receiptStartDate,
    DateTime? receiptEndDate,
    String? statusNr,
    String? deliveryCountry,
    String? deliveryZipCode,
    String? receiptZipCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    Iterable<OrderModel> filtered = _orders;

    if (orderCustomerNr != null && orderCustomerNr.trim().isNotEmpty) {
      final q = orderCustomerNr.trim().toLowerCase();
      filtered = filtered.where((o) => (o.orderCustomerNr ?? '').toLowerCase().contains(q));
    }

    if (statusNr != null && statusNr.trim().isNotEmpty) {
      final s = statusNr.trim().toLowerCase();
      filtered = filtered.where((o) => (o.status ?? '').toLowerCase() == s);
    }

    if (deliveryCountry != null && deliveryCountry.trim().isNotEmpty) {
      final c = deliveryCountry.trim().toLowerCase();
      filtered = filtered.where((o) => o.deliveryPoint.country.toLowerCase() == c);
    }

    if (deliveryZipCode != null && deliveryZipCode.trim().isNotEmpty) {
      final z = deliveryZipCode.trim().toLowerCase();
      filtered = filtered.where((o) => o.deliveryPoint.zipCode.toLowerCase().contains(z));
    }

    if (receiptZipCode != null && receiptZipCode.trim().isNotEmpty) {
      final z = receiptZipCode.trim().toLowerCase();
      filtered = filtered.where((o) => o.receiptPoint.zipCode.toLowerCase().contains(z));
    }

    if (receiptStartDate != null) {
      filtered = filtered.where((o) => (o.receiptDateBegin ?? DateTime(0)).isAfter(receiptStartDate) ||
          (o.receiptDateBegin ?? DateTime(0)).isAtSameMomentAs(receiptStartDate));
    }

    if (receiptEndDate != null) {
      filtered = filtered.where((o) => (o.receiptDateEnd ?? o.receiptDateBegin ?? DateTime(9999))
          .isBefore(receiptEndDate) ||
          (o.receiptDateEnd ?? o.receiptDateBegin ?? DateTime(9999)).isAtSameMomentAs(receiptEndDate));
    }

    if (deliveryStartDate != null) {
      filtered = filtered.where((o) => (o.deliveryDateBegin ?? DateTime(0)).isAfter(deliveryStartDate) ||
          (o.deliveryDateBegin ?? DateTime(0)).isAtSameMomentAs(deliveryStartDate));
    }

    if (deliveryEndDate != null) {
      filtered = filtered.where((o) => (o.deliveryDateEnd ?? o.deliveryDateBegin ?? DateTime(9999))
          .isBefore(deliveryEndDate) ||
          (o.deliveryDateEnd ?? o.deliveryDateBegin ?? DateTime(9999)).isAtSameMomentAs(deliveryEndDate));
    }

    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return [];

    return filtered.skip(start).take(pageSize).toList();
  }

  @override
  Future<List<OrderModel>> getOrdersHistory() async => _pricingRepo.debugOrders();

  @override
  Future<List<Quotation>> getQuotationsConverted() async =>
      _pricingRepo.debugQuotations().where((p) => (p.orderNrSl ?? '').isNotEmpty).toList();

  @override
  Future<void> cancelOrder(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final byOrderId = int.tryParse(id);
    final idx = _orders.indexWhere((o) {
      if (byOrderId != null) return o.orderId == byOrderId;
      final nr = (o.orderNr ?? '').trim();
      return nr.isNotEmpty && nr == id;
    });
    if (idx < 0) {
      throw Exception('Order not found');
    }
    final current = _orders[idx];
    _orders[idx] = _copyWithStatus(current, 'CANCELED');
  }

  OrderModel _copyWithStatus(OrderModel o, String status) {
    return OrderModel(
      quotationId: o.quotationId,
      receiptPoint: o.receiptPoint,
      deliveryPoint: o.deliveryPoint,
      loads: o.loads,
      receiptDateBegin: o.receiptDateBegin,
      receiptDateEnd: o.receiptDateEnd,
      deliveryDateBegin: o.deliveryDateBegin,
      deliveryDateEnd: o.deliveryDateEnd,
      orderCustomerNr: o.orderCustomerNr,
      orderValue: o.orderValue,
      orderValueCurrency: o.orderValueCurrency,
      notificationEmail: o.notificationEmail,
      notificationSms: o.notificationSms,
      instructionCodes: o.instructionCodes,
      orderId: o.orderId,
      orderNr: o.orderNr,
      stageTtNr: o.stageTtNr,
      status: status,
      errors: o.errors,
    );
  }
}
