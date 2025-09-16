import 'quotation_item.dart';

class QuotationPostModel {
  final int? id;
  final String? guid;
  final int? additionalService;
  final double? additionalServicePrice;
  final bool? adr;
  final double? adrPrice;
  final double? allIn;
  final String? comments;
  final bool? insurance;
  final String? insuranceCurrency;
  final double? insurancePrice;
  final double? insuranceValue;
  final double? shippingPrice;
  final String? ttTime;
  final int deliveryCountry;     // required
  final String deliveryZipCode;  // required
  final int? receiptCountry;
  final String receiptZipCode;   // required
  final String? userName;
  final DateTime? createDate;
  final int? status;
  final double? weightChgw;
  final String? orderNrSl;
  final DateTime? orderDateSl;
  final double? baf;
  final double? taf;
  final double? inflCorrection;
  final List<QuotationItem>? quotationItems;

  const QuotationPostModel({
    this.id,
    this.guid,
    this.additionalService,
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
    required this.deliveryCountry,
    required this.deliveryZipCode,
    this.receiptCountry,
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
    this.quotationItems,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'guid': guid,
    'additionalService': additionalService,
    'additionalServicePrice': additionalServicePrice,
    'adr': adr,
    'adrPrice': adrPrice,
    'allIn': allIn,
    'comments': comments,
    'insurance': insurance,
    'insuranceCurrency': insuranceCurrency,
    'insurancePrice': insurancePrice,
    'insuranceValue': insuranceValue,
    'shippingPrice': shippingPrice,
    'ttTime': ttTime,
    'deliveryCountry': deliveryCountry,
    'deliveryZipCode': deliveryZipCode,
    'receiptCountry': receiptCountry,
    'receiptZipCode': receiptZipCode,
    'userName': userName,
    'createDate': createDate?.toIso8601String(),
    'status': status,
    'weightChgw': weightChgw,
    'orderNrSl': orderNrSl,
    'orderDateSl': orderDateSl?.toIso8601String(),
    'baf': baf,
    'taf': taf,
    'inflCorrection': inflCorrection,
    'pricingPositions': quotationItems?.map((e) => e.toJson()).toList(),
  };
}
