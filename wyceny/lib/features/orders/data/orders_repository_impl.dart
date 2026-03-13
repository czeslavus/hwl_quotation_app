import 'package:dio/dio.dart';
import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/orders/domain/orders_repository.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._dio);

  final Dio _dio;

  static const String _ordersPath = '/orders';

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
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (_hasText(orderCustomerNr)) 'orderCustomerNr': orderCustomerNr!.trim(),
      if (deliveryStartDate != null)
        'deliveryStartDate': deliveryStartDate.toUtc().toIso8601String(),
      if (deliveryEndDate != null)
        'deliveryEndDate': deliveryEndDate.toUtc().toIso8601String(),
      if (receiptStartDate != null)
        'receiptStartDate': receiptStartDate.toUtc().toIso8601String(),
      if (receiptEndDate != null)
        'receiptEndDate': receiptEndDate.toUtc().toIso8601String(),
      if (_hasText(statusNr)) 'statusNr': statusNr!.trim(),
      if (_hasText(deliveryCountry)) 'deliveryCountry': deliveryCountry!.trim(),
      if (_hasText(deliveryZipCode)) 'deliveryZipCode': deliveryZipCode!.trim(),
      if (_hasText(receiptZipCode)) 'receiptZipCode': receiptZipCode!.trim(),
    };

    final res = await _dio.get(
      _ordersPath,
      queryParameters: query,
    );
    return _parseOrderList(
      res.data,
      requestOptions: res.requestOptions,
      response: res,
    );
  }

  @override
  Future<List<OrderModel>> getOrdersHistory() {
    // No dedicated history endpoint in the current API contract.
    return getOrders(page: 1, pageSize: 100);
  }

  @override
  Future<List<Quotation>> getQuotationsConverted() async {
    throw UnsupportedError(
      'No API endpoint for converted quotations in OrdersRepository',
    );
  }

  @override
  Future<void> cancelOrder(String id) async {
    throw UnsupportedError('No API endpoint for order cancellation');
  }

  List<OrderModel> _parseOrderList(
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
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}
