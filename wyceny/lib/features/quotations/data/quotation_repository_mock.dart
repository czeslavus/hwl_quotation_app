import 'dart:math';
import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/quotations/domain/models/dictionaries/dicts.dart';
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
    for (var i = 0; i < 12; i++) {
      final id = _idSeq++;
      final p = Quotation(
        id: id,
        guid: 'G$id',
        deliveryCountry: 616,          // PL
        deliveryZipCode: '00-00${i % 10}',
        receiptZipCode: '11-11${i % 10}',
        receiptCountry: 276,           // DE
        createDate: DateTime.now().subtract(Duration(days: 30 - i)),
        status: (i % 4) + 1,
        shippingPrice: 120.0 + i,
        quotationItems: [
          QuotationItem(
            id: null,
            quotationId: id,
            quantity: 1 + (i % 3),
            length: 120,
            width: 80,
            height: 60,
            weight: 200,
            stackability: true,
          )
        ],
      );
      _byId[id] = p;
      _archive.add(p);
    }
  }

  @override
  Future<Quotation> getQuotation(int id) async {
    final p = _byId[id];
    if (p == null) throw Exception('Quotation not found');
    return p;
  }

  @override
  Future<List<Quotation>> getArchive({
    int page = 1,
    int pageSize = 10,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? originCountryId,
    int? destCountryId
  }) async {
    final start = (page - 1) * pageSize;
    return _archive.skip(start).take(pageSize).toList();
  }

  @override
  Future<Quotation> create(QuotationPostModel model) async {
    final id = _idSeq++;
    final p = Quotation(
      id: id,
      guid: model.guid ?? 'G$id',
      deliveryCountry: model.deliveryCountry,
      deliveryZipCode: model.deliveryZipCode,
      receiptCountry: model.receiptCountry,
      receiptZipCode: model.receiptZipCode,
      userName: model.userName,
      createDate: model.createDate ?? DateTime.now(),
      status: model.status ?? 1,
      additionalService: model.additionalService,
      additionalServicePrice: model.additionalServicePrice,
      adr: model.adr,
      adrPrice: model.adrPrice,
      allIn: model.allIn,
      comments: model.comments,
      insurance: model.insurance,
      insuranceCurrency: model.insuranceCurrency,
      insurancePrice: model.insurancePrice,
      insuranceValue: model.insuranceValue,
      shippingPrice: model.shippingPrice,
      ttTime: model.ttTime,
      weightChgw: model.weightChgw,
      orderNrSl: model.orderNrSl,
      orderDateSl: model.orderDateSl,
      baf: model.baf,
      taf: model.taf,
      inflCorrection: model.inflCorrection,
      quotationItems: model.quotationItems,
    );
    _byId[id] = p;
    _archive.insert(0, p);
    return p;
  }

  @override
  Future<Quotation> update(QuotationPostModel model) async {
    if (model.id == null) throw Exception('Id required for update');
    final existing = await getQuotation(model.id!);
    final updated = Quotation(
      id: existing.id,
      guid: model.guid ?? existing.guid,
      deliveryCountry: model.deliveryCountry,
      deliveryZipCode: model.deliveryZipCode,
      receiptCountry: model.receiptCountry,
      receiptZipCode: model.receiptZipCode,
      userName: model.userName ?? existing.userName,
      createDate: model.createDate ?? existing.createDate,
      status: model.status ?? existing.status,
      additionalService: model.additionalService ?? existing.additionalService,
      additionalServicePrice: model.additionalServicePrice ?? existing.additionalServicePrice,
      adr: model.adr ?? existing.adr,
      adrPrice: model.adrPrice ?? existing.adrPrice,
      allIn: model.allIn ?? existing.allIn,
      comments: model.comments ?? existing.comments,
      insurance: model.insurance ?? existing.insurance,
      insuranceCurrency: model.insuranceCurrency ?? existing.insuranceCurrency,
      insurancePrice: model.insurancePrice ?? existing.insurancePrice,
      insuranceValue: model.insuranceValue ?? existing.insuranceValue,
      shippingPrice: model.shippingPrice ?? existing.shippingPrice,
      ttTime: model.ttTime ?? existing.ttTime,
      weightChgw: model.weightChgw ?? existing.weightChgw,
      orderNrSl: model.orderNrSl ?? existing.orderNrSl,
      orderDateSl: model.orderDateSl ?? existing.orderDateSl,
      baf: model.baf ?? existing.baf,
      taf: model.taf ?? existing.taf,
      inflCorrection: model.inflCorrection ?? existing.inflCorrection,
      quotationItems: model.quotationItems ?? existing.quotationItems,
    );
    _byId[existing.id!] = updated;
    final idx = _archive.indexWhere((x) => x.id == existing.id);
    if (idx >= 0) _archive[idx] = updated;
    return updated;
  }

  // --- słowniki ---
  @override
  Future<List<Country>> getCountries() async => [
    Country(id: 616, country: 'Poland'),
    Country(id: 276, country: 'Germany'),
    Country(id: 203, country: 'Czechia'),
  ];

  @override
  Future<List<Addition>> getAdditions() async => [
    Addition(id: 1, type: 'LIFTGATE', value: 35.0),
    Addition(id: 2, type: 'INSIDE_DELIVERY', value: 22.0),
  ];

  @override
  Future<List<ServiceDict>> getServices() async => [
    ServiceDict(id: 1, name: 'FTL', description: 'Full Truck Load'),
    ServiceDict(id: 2, name: 'LTL', description: 'Less Than Truck Load'),
  ];

  @override
  Future<List<StatusDict>> getStatuses() async => [
    StatusDict(id: 1, name: 'Draft'),
    StatusDict(id: 2, name: 'Proposed'),
    StatusDict(id: 3, name: 'Approved'),
    StatusDict(id: 4, name: 'Rejected'),
  ];

  // --- akcje ---
  @override
  Future<Quotation> copy(int id) async {
    final src = await getQuotation(id);
    final newId = _idSeq++;
    final copy = Quotation(
      id: newId,
      guid: 'G$newId',
      deliveryCountry: src.deliveryCountry,
      deliveryZipCode: src.deliveryZipCode,
      receiptCountry: src.receiptCountry,
      receiptZipCode: src.receiptZipCode,
      createDate: DateTime.now(),
      status: 1,
      quotationItems: src.quotationItems,
      shippingPrice: src.shippingPrice,
      comments: 'Copy of ${src.guid}',
    );
    _byId[newId] = copy;
    _archive.insert(0, copy);
    return copy;
  }

  @override
  Future<Quotation> approve(int id) async {
    final p = await getQuotation(id);
    final approved = Quotation(
      id: p.id,
      guid: p.guid,
      deliveryCountry: p.deliveryCountry,
      deliveryZipCode: p.deliveryZipCode,
      receiptCountry: p.receiptCountry,
      receiptZipCode: p.receiptZipCode,
      createDate: p.createDate,
      status: 3, // Approved
      quotationItems: p.quotationItems,
      shippingPrice: p.shippingPrice,
      comments: p.comments,
    );
    _byId[p.id!] = approved;
    final idx = _archive.indexWhere((x) => x.id == p.id);
    if (idx >= 0) _archive[idx] = approved;
    return approved;
  }

  @override
  Future<Quotation> reject(RejectModel model) async {
    final p = await getQuotation(model.quotationId);
    final rejected = Quotation(
      id: p.id,
      guid: p.guid,
      deliveryCountry: p.deliveryCountry,
      deliveryZipCode: p.deliveryZipCode,
      receiptCountry: p.receiptCountry,
      receiptZipCode: p.receiptZipCode,
      createDate: p.createDate,
      status: 4, // Rejected
      quotationItems: p.quotationItems,
      shippingPrice: p.shippingPrice,
      comments: 'Rejected: ${model.reason}',
    );
    _byId[p.id!] = rejected;
    final idx = _archive.indexWhere((x) => x.id == p.id);
    if (idx >= 0) _archive[idx] = rejected;
    return rejected;
  }

  // --- wycena -> zamówienie ---
  @override
  Future<OrderModel> buildOrderFromQuotation(int id) async {
    final p = await getQuotation(id);
    // prosta projekcja pól, zgodna z GET /api/pricings/sendorder/{id}
    return OrderModel(
      quotationId: p.id!,
      receiptAddress: 'Receipt addr for ${p.guid}',
      receiptCity: 'City R',
      receiptStreet: 'Street R 1',
      receiptCityZipCode: p.receiptZipCode,
      deliveryAddress: 'Delivery addr for ${p.guid}',
      deliveryCity: 'City D',
      deliveryCountry: 'POL', // mock 3-chars
      deliveryStreet: 'Street D 2',
      deliveryCityZipCode: p.deliveryZipCode,
    );
  }

  @override
  Future<String> sendOrder(OrderModel model) async {
    // Zapisz w historii "orders"
    _orders.add(model);
    // Zaktualizuj pricing jako "wysłany"
    final p = await getQuotation(model.quotationId);
    final updated = Quotation(
      id: p.id,
      guid: p.guid,
      deliveryCountry: p.deliveryCountry,
      deliveryZipCode: p.deliveryZipCode,
      receiptCountry: p.receiptCountry,
      receiptZipCode: p.receiptZipCode,
      createDate: p.createDate,
      status: 3, // Approved -> wysłany
      quotationItems: p.quotationItems,
      shippingPrice: p.shippingPrice,
      orderNrSl: 'ORD-${p.id}-${Random().nextInt(9999)}',
      orderDateSl: DateTime.now(),
      comments: p.comments,
    );
    _byId[p.id!] = updated;
    final idx = _archive.indexWhere((x) => x.id == p.id);
    if (idx >= 0) _archive[idx] = updated;

    return updated.orderNrSl!;
  }

  // Ekspozycje dla repo historii zamówień
  List<OrderModel> debugOrders() => List.unmodifiable(_orders);
  List<Quotation> debugQuotations() => List.unmodifiable(_archive);
}
