import 'package:wyceny/features/quotations/domain/models/quotation_item.dart';

class Quotation {
  /// API: quotationId (nullable w response)
  final int? quotationId;

  /// API: additionalServiceId (nullable)
  final int? additionalServiceId;

  /// API: adr (nullable)
  final bool? adr;

  /// API: insuranceCurrency (nullable)
  final String? insuranceCurrency;

  /// API: insurancePrice (nullable)
  final double? insurancePrice;

  /// API: insuranceValue (nullable)
  final double? insuranceValue;

  /// API: deliveryCountryId (required)
  final int deliveryCountryId;

  /// API: deliveryZipCode (required)
  final String deliveryZipCode;

  /// API: receiptZipCode (required)
  final String receiptZipCode;

  /// API: userName (nullable)
  final String? userName;

  /// API: quotationPositions (nullable)
  final List<QuotationItem>? quotationPositions;

  // ---- Pola występujące w QuotationResponse (część nie występuje w Request) ----

  /// API: additionalServicePrice (nullable)
  final double? additionalServicePrice;

  /// API: adrPrice (nullable)
  final double? adrPrice;

  /// API: allIn (nullable)
  final double? allIn;

  /// API: comments (nullable)
  final String? comments;

  /// API: insurance (nullable)
  final bool? insurance;

  /// API: shippingPrice (nullable)
  final double? shippingPrice;

  /// API: ttTime (nullable)
  final String? ttTime;

  /// API: createDate (nullable, date-time)
  final DateTime? createDate;

  /// API: status (nullable)
  final int? status;

  /// API: weightChgw (nullable)
  final double? weightChgw;

  /// API: orderNrSl (nullable)
  final String? orderNrSl;

  /// API: orderDateSl (nullable, date-time)
  final DateTime? orderDateSl;

  /// API: baf/taf/inflCorrection (nullable)
  final double? baf;
  final double? taf;
  final double? inflCorrection;

  const Quotation({
    this.quotationId,
    this.additionalServiceId,
    this.adr,
    this.insuranceCurrency,
    this.insurancePrice,
    this.insuranceValue,
    required this.deliveryCountryId,
    required this.deliveryZipCode,
    required this.receiptZipCode,
    this.userName,
    this.quotationPositions,
    this.additionalServicePrice,
    this.adrPrice,
    this.allIn,
    this.comments,
    this.insurance,
    this.shippingPrice,
    this.ttTime,
    this.createDate,
    this.status,
    this.weightChgw,
    this.orderNrSl,
    this.orderDateSl,
    this.baf,
    this.taf,
    this.inflCorrection,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
    quotationId: json['quotationId'] as int?,
    additionalServiceId: json['additionalServiceId'] as int?,
    adr: json['adr'] as bool?,
    insuranceCurrency: json['insuranceCurrency'] as String?,
    insurancePrice: (json['insurancePrice'] as num?)?.toDouble(),
    insuranceValue: (json['insuranceValue'] as num?)?.toDouble(),
    deliveryCountryId: json['deliveryCountryId'] as int,
    deliveryZipCode: json['deliveryZipCode'] as String,
    receiptZipCode: json['receiptZipCode'] as String,
    userName: json['userName'] as String?,
    quotationPositions: (json['quotationPositions'] as List?)
        ?.map((e) => QuotationItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),

    // Response-only / dodatkowe pola
    additionalServicePrice: (json['additionalServicePrice'] as num?)?.toDouble(),
    adrPrice: (json['adrPrice'] as num?)?.toDouble(),
    allIn: (json['allIn'] as num?)?.toDouble(),
    comments: json['comments'] as String?,
    insurance: json['insurance'] as bool?,
    shippingPrice: (json['shippingPrice'] as num?)?.toDouble(),
    ttTime: json['ttTime'] as String?,
    createDate: json['createDate'] != null ? DateTime.parse(json['createDate'] as String) : null,
    status: json['status'] as int?,
    weightChgw: (json['weightChgw'] as num?)?.toDouble(),
    orderNrSl: json['orderNrSl'] as String?,
    orderDateSl: json['orderDateSl'] != null ? DateTime.parse(json['orderDateSl'] as String) : null,
    baf: (json['baf'] as num?)?.toDouble(),
    taf: (json['taf'] as num?)?.toDouble(),
    inflCorrection: (json['inflCorrection'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'quotationId': quotationId,
    'additionalServiceId': additionalServiceId,
    'adr': adr,
    'insuranceCurrency': insuranceCurrency,
    'insurancePrice': insurancePrice,
    'insuranceValue': insuranceValue,
    'deliveryCountryId': deliveryCountryId,
    'deliveryZipCode': deliveryZipCode,
    'receiptZipCode': receiptZipCode,
    'userName': userName,
    'quotationPositions': quotationPositions?.map((e) => e.toJson()).toList(),

    // Dodatkowe pola (zwykle serwer je wylicza, ale trzymamy w modelu)
    'additionalServicePrice': additionalServicePrice,
    'adrPrice': adrPrice,
    'allIn': allIn,
    'comments': comments,
    'insurance': insurance,
    'shippingPrice': shippingPrice,
    'ttTime': ttTime,
    'createDate': createDate?.toIso8601String(),
    'status': status,
    'weightChgw': weightChgw,
    'orderNrSl': orderNrSl,
    'orderDateSl': orderDateSl?.toIso8601String(),
    'baf': baf,
    'taf': taf,
    'inflCorrection': inflCorrection,
  };
}
