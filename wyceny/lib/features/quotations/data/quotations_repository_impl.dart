import 'package:dio/dio.dart';
import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';
import 'package:wyceny/features/quotations/domain/models/quotation_item.dart';
import 'package:wyceny/features/quotations/domain/models/quotation_post_model.dart';
import 'package:wyceny/features/quotations/domain/models/reject_model.dart';
import 'package:wyceny/features/quotations/domain/quotations_repository.dart';

class QuotationsRepositoryImpl implements QuotationsRepository {
  QuotationsRepositoryImpl(this._dio);

  final Dio _dio;

  static const String _quotationsPath = '/quotations';

  @override
  Future<Quotation> getQuotation(int id) async {
    final res = await _dio.get('$_quotationsPath/$id');
    return _parseQuotation(
      res.data,
      requestOptions: res.requestOptions,
      response: res,
    );
  }

  @override
  Future<List<Quotation>> getArchive({
    int page = 1,
    int pageSize = 10,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? destCountryId,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (dateFrom != null) 'startDate': dateFrom.toUtc().toIso8601String(),
      if (dateTo != null) 'endDate': dateTo.toUtc().toIso8601String(),
      ...?destCountryId == null
          ? null
          : <String, dynamic>{'deliveryCountryId': destCountryId},
    };

    final res = await _dio.get(
      _quotationsPath,
      queryParameters: query,
    );
    return _parseQuotationList(
      res.data,
      requestOptions: res.requestOptions,
      response: res,
    );
  }

  @override
  Future<Quotation> create(QuotationPostModel model) async {
    final res = await _dio.post(
      _quotationsPath,
      data: _toQuotationRequest(model),
    );
    return _parseQuotation(
      res.data,
      requestOptions: res.requestOptions,
      response: res,
      fallbackReceiptCountryId: model.receiptCountryId,
    );
  }

  @override
  Future<Quotation> update(QuotationPostModel model) async {
    final id = model.quotationId;
    if (id == null) {
      throw ArgumentError('quotationId is required for update');
    }

    final res = await _dio.put(
      '$_quotationsPath/$id',
      data: _toQuotationRequest(model),
    );
    return _parseQuotation(
      res.data,
      requestOptions: res.requestOptions,
      response: res,
      fallbackReceiptCountryId: model.receiptCountryId,
    );
  }

  @override
  Future<Quotation> copy(int id) async {
    final source = await getQuotation(id);

    final cloned = QuotationPostModel(
      deliveryCountryId: source.deliveryCountryId,
      deliveryZipCode: source.deliveryZipCode,
      receiptCountryId: source.receiptCountryId,
      receiptZipCode: source.receiptZipCode,
      additionalServiceId: source.additionalServiceId,
      adr: source.adr,
      insuranceCurrency: source.insuranceCurrency,
      insurancePrice: source.insurancePrice,
      insuranceValue: source.insuranceValue,
      userName: source.userName,
      quotationPositions: source.quotationPositions,
    );
    return create(cloned);
  }

  @override
  Future<Quotation> approve(int id) async {
    final res = await _dio.post('$_quotationsPath/$id/approve');
    return _parseQuotation(
      res.data,
      requestOptions: res.requestOptions,
      response: res,
    );
  }

  @override
  Future<Quotation> reject(RejectModel model) async {
    final res = await _dio.post(
      '$_quotationsPath/${model.quotationId}/reject',
      data: model.toJson(),
    );
    return _parseQuotation(
      res.data,
      requestOptions: res.requestOptions,
      response: res,
    );
  }

  @override
  Future<OrderModel> buildOrderFromQuotation(int id) async {
    final res = await _dio.get('/orders/sendorder/quotation/$id');
    final data = res.data;
    if (data is Map) {
      return OrderModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
      error: 'Expected JSON object from /orders/sendorder/quotation/$id',
    );
  }

  @override
  Future<String> sendOrder(OrderModel model) async {
    final quotationId = model.quotationId;
    if (quotationId == null) {
      throw ArgumentError('quotationId is required to send order from quotation');
    }

    final res = await _dio.post(
      '/orders/sendorder/quotation/$quotationId',
      data: model.toJson(),
    );
    final data = res.data;
    if (data is Map) {
      final mapped = Map<String, dynamic>.from(data);
      return (mapped['orderNR'] ?? mapped['orderNr'] ?? '').toString();
    }
    if (data is String) return data;
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
      error: 'Expected JSON object/string from /orders/sendorder/quotation/$quotationId',
    );
  }

  Map<String, dynamic> _toQuotationRequest(QuotationPostModel model) {
    return <String, dynamic>{
      if (model.quotationId != null) 'quotationId': model.quotationId,
      if (model.additionalServiceId != null)
        'additionalServiceId': model.additionalServiceId,
      if (model.adr != null) 'adr': model.adr,
      if (model.insuranceCurrency != null)
        'insuranceCurrency': model.insuranceCurrency,
      if (model.insurancePrice != null) 'insurancePrice': model.insurancePrice,
      if (model.insuranceValue != null) 'insuranceValue': model.insuranceValue,
      'deliveryCountryId': model.deliveryCountryId,
      'deliveryZipCode': model.deliveryZipCode,
      'receiptZipCode': model.receiptZipCode,
      if (model.userName != null) 'userName': model.userName,
      if (model.quotationPositions != null)
        'quotationPositions': model.quotationPositions!
            .map(_toQuotationItemRequest)
            .toList(growable: false),
    };
  }

  Map<String, dynamic> _toQuotationItemRequest(QuotationItem item) {
    return <String, dynamic>{
      if (item.itemId != null) 'itemId': item.itemId,
      'quantity': item.quantity,
      'length': item.length,
      'width': item.width,
      'height': item.height,
      'weight': item.weight,
      if (item.packaging != null) 'packaging': item.packaging,
      if (item.packagingWeight != null) 'packagingWeight': item.packagingWeight,
      if (item.cbm != null) 'cbm': item.cbm,
      if (item.ldm != null) 'ldm': item.ldm,
      if (item.ldmCbm != null) 'ldmCbm': item.ldmCbm,
      if (item.longWeight != null) 'longWeight': item.longWeight,
    };
  }

  Quotation _parseQuotation(
    dynamic data, {
    required RequestOptions requestOptions,
    required Response<dynamic> response,
    int? fallbackReceiptCountryId,
  }) {
    if (data is! Map) {
      throw DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Expected JSON object, got ${data.runtimeType}',
      );
    }
    final map = Map<String, dynamic>.from(data);
    map['receiptCountryId'] = _asInt(map['receiptCountryId']) ??
        fallbackReceiptCountryId ??
        0;
    return Quotation.fromJson(map);
  }

  List<Quotation> _parseQuotationList(
    dynamic data, {
    required RequestOptions requestOptions,
    required Response<dynamic> response,
  }) {
    List<dynamic>? raw;

    if (data is List) {
      raw = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in ['items', 'data', 'result', 'results']) {
        final candidate = map[key];
        if (candidate is List) {
          raw = candidate;
          break;
        }
      }
      raw ??= [map];
    }

    if (raw == null) {
      throw DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Expected JSON array/object, got ${data.runtimeType}',
      );
    }

    return raw
        .whereType<Map>()
        .map((e) => _parseQuotation(
              e,
              requestOptions: requestOptions,
              response: response,
            ))
        .toList(growable: false);
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
