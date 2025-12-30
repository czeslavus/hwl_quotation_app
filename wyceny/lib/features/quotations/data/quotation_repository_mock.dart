import 'dart:math';

import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';
import 'package:wyceny/features/quotations/domain/models/quotation_item.dart';
import 'package:wyceny/features/quotations/domain/models/quotation_post_model.dart';
import 'package:wyceny/features/quotations/domain/models/reject_model.dart';
import 'package:wyceny/features/quotations/domain/quotations_repository.dart';

class MockQuotationsRepository implements QuotationsRepository {
  final List<Quotation> _archive = [];
  final Map<int, Quotation> _byId = {};
  final List<OrderModel> _orders = []; // do śledzenia historii zamówień
  int _idSeq = 100;

  MockQuotationsRepository() {
    // seed przykładowymi danymi
    final random = Random();
    for (var i = 0; i < 12; i++) {
      final id = _idSeq++;
      final q = Quotation(
        quotationId: id,
        deliveryCountryId: random.nextInt(4)+1,
        deliveryZipCode: '00-00${i % 10}',
        receiptCountryId: random.nextInt(4)+1,
        receiptZipCode: '11-11${i % 10}',
        createDate: DateTime.now().subtract(Duration(days: 30 - i)),
        status: (i % 4) + 1,
        shippingPrice: 120.0 + i,
        quotationPositions: [
          QuotationItem(
            itemId: null,
            quantity: 1 + (i % 3),
            length: 120,
            width: 80,
            height: 60,
            weight: 200,
            // w nowym API nie ma stackability
          ),
        ],
        comments: 'Mock quotation #$id',
      );

      _byId[id] = q;
      _archive.add(q);
    }
  }

  @override
  Future<Quotation> getQuotation(int id) async {
    final q = _byId[id];
    if (q == null) throw Exception('Quotation not found');
    return q;
  }

  @override
  Future<List<Quotation>> getArchive({
    int page = 1,
    int pageSize = 10,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? destCountryId,
  }) async {
    Iterable<Quotation> data = _archive;

    if (destCountryId != null) {
      data = data.where((q) => q.deliveryCountryId == destCountryId);
    }
    final l1 = data.toList();

    if (dateFrom != null) {
      final from = DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
      data = data.where((q) => (q.createDate ?? DateTime.fromMillisecondsSinceEpoch(0)).isAfter(from) ||
          (q.createDate ?? DateTime.fromMillisecondsSinceEpoch(0)).isAtSameMomentAs(from));
    }

    if (dateTo != null) {
      // do końca dnia
      final toExclusive = DateTime(dateTo.year, dateTo.month, dateTo.day).add(const Duration(days: 1));
      data = data.where((q) => (q.createDate ?? DateTime.fromMillisecondsSinceEpoch(0)).isBefore(toExclusive));
    }

    final list = data.toList();
    final start = (page - 1) * pageSize;
    if (start >= list.length) return const [];
    return list.skip(start).take(pageSize).toList();
  }

  @override
  Future<Quotation> create(QuotationPostModel model) async {
    final id = _idSeq++;

    final q = Quotation(
      quotationId: id,
      additionalServiceId: model.additionalServiceId,
      adr: model.adr,
      insuranceCurrency: model.insuranceCurrency,
      insurancePrice: model.insurancePrice,
      insuranceValue: model.insuranceValue,
      deliveryCountryId: model.deliveryCountryId,
      deliveryZipCode: model.deliveryZipCode,
      receiptCountryId: model.receiptCountryId,
      receiptZipCode: model.receiptZipCode,
      userName: model.userName,
      quotationPositions: model.quotationPositions,

      // response-like fields (symulacja)
      createDate: model.createDate ?? DateTime.now(),
      status: model.status ?? 1,
      additionalServicePrice: model.additionalServicePrice,
      adrPrice: model.adrPrice,
      allIn: model.allIn,
      comments: model.comments,
      insurance: model.insurance,
      shippingPrice: model.shippingPrice,
      ttTime: model.ttTime,
      weightChgw: model.weightChgw,
      orderNrSl: model.orderNrSl,
      orderDateSl: model.orderDateSl,
      baf: model.baf,
      taf: model.taf,
      inflCorrection: model.inflCorrection,
    );

    await Future.delayed(const Duration(seconds: 2));

    _byId[id] = q;
    _archive.insert(0, q);
    return q;
  }

  @override
  Future<Quotation> update(QuotationPostModel model) async {
    final id = model.quotationId;
    if (id == null) throw Exception('quotationId required for update');

    final existing = await getQuotation(id);

    final updated = Quotation(
      quotationId: existing.quotationId,

      // request fields
      deliveryCountryId: model.deliveryCountryId,
      deliveryZipCode: model.deliveryZipCode,
      receiptCountryId: model.receiptCountryId,
      receiptZipCode: model.receiptZipCode,
      additionalServiceId: model.additionalServiceId ?? existing.additionalServiceId,
      adr: model.adr ?? existing.adr,
      insuranceCurrency: model.insuranceCurrency ?? existing.insuranceCurrency,
      insurancePrice: model.insurancePrice ?? existing.insurancePrice,
      insuranceValue: model.insuranceValue ?? existing.insuranceValue,
      userName: model.userName ?? existing.userName,
      quotationPositions: model.quotationPositions ?? existing.quotationPositions,

      // response-like fields
      createDate: model.createDate ?? existing.createDate,
      status: model.status ?? existing.status,
      additionalServicePrice: model.additionalServicePrice ?? existing.additionalServicePrice,
      adrPrice: model.adrPrice ?? existing.adrPrice,
      allIn: model.allIn ?? existing.allIn,
      comments: model.comments ?? existing.comments,
      insurance: model.insurance ?? existing.insurance,
      shippingPrice: model.shippingPrice ?? existing.shippingPrice,
      ttTime: model.ttTime ?? existing.ttTime,
      weightChgw: model.weightChgw ?? existing.weightChgw,
      orderNrSl: model.orderNrSl ?? existing.orderNrSl,
      orderDateSl: model.orderDateSl ?? existing.orderDateSl,
      baf: model.baf ?? existing.baf,
      taf: model.taf ?? existing.taf,
      inflCorrection: model.inflCorrection ?? existing.inflCorrection,
    );

    await Future.delayed(const Duration(seconds: 2));

    _byId[id] = updated;
    final idx = _archive.indexWhere((x) => x.quotationId == id);
    if (idx >= 0) _archive[idx] = updated;

    return updated;
  }


  // --- akcje ---
  @override
  Future<Quotation> copy(int id) async {
    final src = await getQuotation(id);
    final newId = _idSeq++;

    final copied = Quotation(
      quotationId: newId,
      deliveryCountryId: src.deliveryCountryId,
      deliveryZipCode: src.deliveryZipCode,
      receiptCountryId: src.receiptCountryId,
      receiptZipCode: src.receiptZipCode,
      createDate: DateTime.now(),
      status: 1,
      quotationPositions: src.quotationPositions,
      shippingPrice: src.shippingPrice,
      comments: 'Copy of quotationId=${src.quotationId}',
      additionalServiceId: src.additionalServiceId,
      adr: src.adr,
      insuranceCurrency: src.insuranceCurrency,
      insurancePrice: src.insurancePrice,
      insuranceValue: src.insuranceValue,
      userName: src.userName,
    );

    _byId[newId] = copied;
    _archive.insert(0, copied);
    return copied;
  }

  @override
  Future<Quotation> approve(int id) async {
    final q = await getQuotation(id);

    final approved = Quotation(
      quotationId: q.quotationId,
      deliveryCountryId: q.deliveryCountryId,
      deliveryZipCode: q.deliveryZipCode,
      receiptCountryId: q.receiptCountryId,
      receiptZipCode: q.receiptZipCode,
      createDate: q.createDate,
      status: 3, // Approved
      quotationPositions: q.quotationPositions,
      shippingPrice: q.shippingPrice,
      comments: q.comments,
      additionalServiceId: q.additionalServiceId,
      adr: q.adr,
      insuranceCurrency: q.insuranceCurrency,
      insurancePrice: q.insurancePrice,
      insuranceValue: q.insuranceValue,
      userName: q.userName,
    );

    _byId[id] = approved;
    final idx = _archive.indexWhere((x) => x.quotationId == id);
    if (idx >= 0) _archive[idx] = approved;

    return approved;
  }

  @override
  Future<Quotation> reject(RejectModel model) async {
    final q = await getQuotation(model.quotationId);

    final rejected = Quotation(
      quotationId: q.quotationId,
      deliveryCountryId: q.deliveryCountryId,
      deliveryZipCode: q.deliveryZipCode,
      receiptCountryId: q.receiptCountryId,
      receiptZipCode: q.receiptZipCode,
      createDate: q.createDate,
      status: 4, // Rejected
      quotationPositions: q.quotationPositions,
      shippingPrice: q.shippingPrice,
      comments: 'Rejected: ${model.rejectCause ?? model.rejectCauseId}',
      additionalServiceId: q.additionalServiceId,
      adr: q.adr,
      insuranceCurrency: q.insuranceCurrency,
      insurancePrice: q.insurancePrice,
      insuranceValue: q.insuranceValue,
      userName: q.userName,
    );

    _byId[q.quotationId!] = rejected;
    final idx = _archive.indexWhere((x) => x.quotationId == q.quotationId);
    if (idx >= 0) _archive[idx] = rejected;

    return rejected;
  }

  // --- wycena -> zamówienie ---
  @override
  Future<OrderModel> buildOrderFromQuotation(int id) async {
    final q = await getQuotation(id);

    // prosta projekcja pól (mock)
    return OrderModel(
      quotationId: q.quotationId!,
      receiptAddress: 'Receipt addr for quotationId=${q.quotationId}',
      receiptCity: 'City R',
      receiptStreet: 'Street R 1',
      receiptCityZipCode: q.receiptZipCode,
      deliveryAddress: 'Delivery addr for quotationId=${q.quotationId}',
      deliveryCity: 'City D',
      deliveryCountry: 'POL', // mock 3-chars
      deliveryStreet: 'Street D 2',
      deliveryCityZipCode: q.deliveryZipCode,
    );
  }

  @override
  Future<String> sendOrder(OrderModel model) async {
    _orders.add(model);

    final q = await getQuotation(model.quotationId);

    // symulacja: "wysłany" + numer zamówienia
    final updated = Quotation(
      quotationId: q.quotationId,
      deliveryCountryId: q.deliveryCountryId,
      deliveryZipCode: q.deliveryZipCode,
      receiptCountryId: q.receiptCountryId,
      receiptZipCode: q.receiptZipCode,
      createDate: q.createDate,
      status: 3, // Approved -> wysłany
      quotationPositions: q.quotationPositions,
      shippingPrice: q.shippingPrice,
      orderNrSl: 'ORD-${q.quotationId}-${Random().nextInt(9999)}',
      orderDateSl: DateTime.now(),
      comments: q.comments,
      additionalServiceId: q.additionalServiceId,
      adr: q.adr,
      insuranceCurrency: q.insuranceCurrency,
      insurancePrice: q.insurancePrice,
      insuranceValue: q.insuranceValue,
      userName: q.userName,
    );

    final id = q.quotationId!;
    _byId[id] = updated;
    final idx = _archive.indexWhere((x) => x.quotationId == id);
    if (idx >= 0) _archive[idx] = updated;

    return updated.orderNrSl!;
  }

  // Ekspozycje dla debug/historii
  List<OrderModel> debugOrders() => List.unmodifiable(_orders);
  List<Quotation> debugQuotations() => List.unmodifiable(_archive);
}
