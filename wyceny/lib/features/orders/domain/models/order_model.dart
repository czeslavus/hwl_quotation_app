class OrderModel {
  final int quotationId;
  final String receiptAddress;
  final String receiptCity;
  final String receiptStreet;
  final String receiptCityZipCode;

  final String deliveryAddress;
  final String deliveryCity;
  final String deliveryCountry;      // 3-chars
  final String deliveryStreet;
  final String deliveryCityZipCode;

  const OrderModel({
    required this.quotationId,
    required this.receiptAddress,
    required this.receiptCity,
    required this.receiptStreet,
    required this.receiptCityZipCode,
    required this.deliveryAddress,
    required this.deliveryCity,
    required this.deliveryCountry,
    required this.deliveryStreet,
    required this.deliveryCityZipCode,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    quotationId: json['pricingId'],
    receiptAddress: json['receiptAddress'],
    receiptCity: json['receiptCity'],
    receiptStreet: json['receiptStreet'],
    receiptCityZipCode: json['receiptCityZipCode'],
    deliveryAddress: json['deliveryAddress'],
    deliveryCity: json['deliveryCity'],
    deliveryCountry: json['deliveryCountry'],
    deliveryStreet: json['deliveryStreet'],
    deliveryCityZipCode: json['deliveryCityZipCode'],
  );

  Map<String, dynamic> toJson() => {
    'pricingId': quotationId,
    'receiptAddress': receiptAddress,
    'receiptCity': receiptCity,
    'receiptStreet': receiptStreet,
    'receiptCityZipCode': receiptCityZipCode,
    'deliveryAddress': deliveryAddress,
    'deliveryCity': deliveryCity,
    'deliveryCountry': deliveryCountry,
    'deliveryStreet': deliveryStreet,
    'deliveryCityZipCode': deliveryCityZipCode,
  };
}
