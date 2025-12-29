import 'package:wyceny/features/quotations/domain/models/quotation_item.dart';

class QuotationPostModel {
  /// API: quotationId (nullable)
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

  // --- pola dodatkowe (przydatne w UI/mockach; serwer zwykle je wylicza) ---
  final double? additionalServicePrice;
  final double? adrPrice;
  final double? allIn;
  final String? comments;
  final bool? insurance;
  final double? shippingPrice;
  final String? ttTime;
  final DateTime? createDate;
  final int? status;
  final double? weightChgw;
  final String? orderNrSl;
  final DateTime? orderDateSl;
  final double? baf;
  final double? taf;
  final double? inflCorrection;

  const QuotationPostModel({
    this.quotationId,
    this.additionalServiceId,
    this.additionalServicePrice,
    this.adr,
    this.adrPrice,
    this.allIn,
    this.comments,
    this.insurance,
    this.insuranceCurrency,
    this.insurancePrice,
    this.insuranceValue,
    this.shippingPrice,
    this.ttTime,
    required this.deliveryCountryId,
    required this.deliveryZipCode,
    required this.receiptZipCode,
    this.userName,
    this.createDate,
    this.status,
    this.weightChgw,
    this.orderNrSl,
    this.orderDateSl,
    this.baf,
    this.taf,
    this.inflCorrection,
    this.quotationPositions,
  });

  /// JSON zgodny z QuotationRequest z OpenAPI:
  /// - quotationId
  /// - additionalServiceId
  /// - adr
  /// - insuranceCurrency / insurancePrice / insuranceValue
  /// - deliveryCountryId / deliveryZipCode / receiptZipCode
  /// - userName
  /// - quotationPositions
  ///
  /// Dodatkowe pola są zostawione (mogą się przydać w mockach),
  /// ale jeśli backend tego nie akceptuje w POST/PUT, usuń je z mapy.
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

    // pola dodatkowe (opcjonalnie)
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
