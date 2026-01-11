class OrderModel {
  final int? quotationId;
  final AddressModel receiptPoint;
  final AddressModel deliveryPoint;
  final List<LoadModel>? loads;
  final DateTime? receiptDateBegin;
  final DateTime? receiptDateEnd;
  final DateTime? deliveryDateBegin;
  final DateTime? deliveryDateEnd;
  final String? orderCustomerNr;
  final double? orderValue;
  final String? orderValueCurrency;
  final String? notificationEmail;
  final String? notificationSms;
  final List<InstructionCodeModel>? instructionCodes;

  // response-only fields
  final int? orderId;
  final String? orderNr;
  final String? stageTtNr;
  final String? status;
  final List<String>? errors;

  const OrderModel({
    required this.quotationId,
    required this.receiptPoint,
    required this.deliveryPoint,
    this.loads,
    this.receiptDateBegin,
    this.receiptDateEnd,
    this.deliveryDateBegin,
    this.deliveryDateEnd,
    this.orderCustomerNr,
    this.orderValue,
    this.orderValueCurrency,
    this.notificationEmail,
    this.notificationSms,
    this.instructionCodes,
    this.orderId,
    this.orderNr,
    this.stageTtNr,
    this.status,
    this.errors,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        quotationId: _asInt(json['quotationId']),
        receiptPoint: AddressModel.fromJson(json['receiptPoint'] as Map<String, dynamic>),
        deliveryPoint: AddressModel.fromJson(json['deliveryPoint'] as Map<String, dynamic>),
        loads: (json['loads'] as List<dynamic>?)
            ?.map((e) => LoadModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        receiptDateBegin: _asDate(json['receiptDateBegin']),
        receiptDateEnd: _asDate(json['receiptDateEnd']),
        deliveryDateBegin: _asDate(json['deliveryDateBegin']),
        deliveryDateEnd: _asDate(json['deliveryDateEnd']),
        orderCustomerNr: json['orderCustomerNR'] as String?,
        orderValue: _asDouble(json['orderValue']),
        orderValueCurrency: json['orderValueCurrency'] as String?,
        notificationEmail: json['notificationEmail'] as String?,
        notificationSms: json['notificationSms'] as String?,
        instructionCodes: (json['instructionCodes'] as List<dynamic>?)
            ?.map((e) => InstructionCodeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        orderId: _asInt(json['orderID']),
        orderNr: json['orderNR'] as String?,
        stageTtNr: json['stageTTNR'] as String?,
        status: json['status'] as String?,
        errors: (json['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'quotationId': quotationId,
        'receiptPoint': receiptPoint.toJson(),
        'deliveryPoint': deliveryPoint.toJson(),
        'loads': loads?.map((e) => e.toJson()).toList(),
        'receiptDateBegin': receiptDateBegin?.toIso8601String(),
        'receiptDateEnd': receiptDateEnd?.toIso8601String(),
        'deliveryDateBegin': deliveryDateBegin?.toIso8601String(),
        'deliveryDateEnd': deliveryDateEnd?.toIso8601String(),
        'orderCustomerNR': orderCustomerNr,
        'orderValue': orderValue,
        'orderValueCurrency': orderValueCurrency,
        'notificationEmail': notificationEmail,
        'notificationSms': notificationSms,
        'instructionCodes': instructionCodes?.map((e) => e.toJson()).toList(),
        'orderID': orderId,
        'orderNR': orderNr,
        'stageTTNR': stageTtNr,
        'status': status,
        'errors': errors,
      };

  int get itemsCount {
    if (loads == null || loads!.isEmpty) return 0;
    final sum = loads!.fold<int>(0, (s, l) => s + (l.unitQuantity ?? 0));
    return sum == 0 ? loads!.length : sum;
  }

  double get totalWeight {
    if (loads == null || loads!.isEmpty) return 0;
    return loads!.fold<double>(0, (s, l) => s + (l.weight ?? 0));
  }
}

class AddressModel {
  final String name;
  final String city;
  final String street;
  final String zipCode;
  final String country;
  final String? phoneNr;

  const AddressModel({
    required this.name,
    required this.city,
    required this.street,
    required this.zipCode,
    required this.country,
    this.phoneNr,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        name: json['name'] as String? ?? '',
        city: json['city'] as String? ?? '',
        street: json['street'] as String? ?? '',
        zipCode: json['zipCode'] as String? ?? '',
        country: json['country'] as String? ?? '',
        phoneNr: json['phoneNr'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'street': street,
        'zipCode': zipCode,
        'country': country,
        'phoneNr': phoneNr,
      };
}

class InstructionCodeModel {
  final String instructionCodeNr;
  final String? instructionCodeInfo;

  const InstructionCodeModel({
    required this.instructionCodeNr,
    this.instructionCodeInfo,
  });

  factory InstructionCodeModel.fromJson(Map<String, dynamic> json) => InstructionCodeModel(
        instructionCodeNr: json['instructionCodeNr'] as String? ?? '',
        instructionCodeInfo: json['instructionCodeInfo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'instructionCodeNr': instructionCodeNr,
        'instructionCodeInfo': instructionCodeInfo,
      };
}

class LoadModel {
  final double? weight;
  final double? volume;
  final double? length;
  final double? width;
  final double? height;
  final String? unitType;
  final int? unitQuantity;
  final List<LoadAdrModel>? loadAdrs;

  const LoadModel({
    this.weight,
    this.volume,
    this.length,
    this.width,
    this.height,
    this.unitType,
    this.unitQuantity,
    this.loadAdrs,
  });

  factory LoadModel.fromJson(Map<String, dynamic> json) => LoadModel(
        weight: _asDouble(json['weight']),
        volume: _asDouble(json['volume']),
        length: _asDouble(json['lenght']),
        width: _asDouble(json['width']),
        height: _asDouble(json['height']),
        unitType: json['unitType'] as String?,
        unitQuantity: _asInt(json['unitQuantity']),
        loadAdrs: (json['loadADRs'] as List<dynamic>?)
            ?.map((e) => LoadAdrModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'volume': volume,
        'lenght': length,
        'width': width,
        'height': height,
        'unitType': unitType,
        'unitQuantity': unitQuantity,
        'loadADRs': loadAdrs?.map((e) => e.toJson()).toList(),
      };
}

class LoadAdrModel {
  final int? row;
  final double? weight;
  final String? name;
  final int? packageUnitQuantity;
  final String? packageUnitType;
  final AdrModel? adrFull;

  const LoadAdrModel({
    this.row,
    this.weight,
    this.name,
    this.packageUnitQuantity,
    this.packageUnitType,
    this.adrFull,
  });

  factory LoadAdrModel.fromJson(Map<String, dynamic> json) => LoadAdrModel(
        row: _asInt(json['row']),
        weight: _asDouble(json['weight']),
        name: json['name'] as String?,
        packageUnitQuantity: _asInt(json['packageUnitQuantity']),
        packageUnitType: json['packageUnitType'] as String?,
        adrFull: json['adrFull'] == null
            ? null
            : AdrModel.fromJson(json['adrFull'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'row': row,
        'weight': weight,
        'name': name,
        'packageUnitQuantity': packageUnitQuantity,
        'packageUnitType': packageUnitType,
        'adrFull': adrFull?.toJson(),
      };
}

class AdrModel {
  final String? adrUn;
  final String? adrName;
  final String? adrClass;
  final String? packingGroup;
  final String? tremcard;

  const AdrModel({
    this.adrUn,
    this.adrName,
    this.adrClass,
    this.packingGroup,
    this.tremcard,
  });

  factory AdrModel.fromJson(Map<String, dynamic> json) => AdrModel(
        adrUn: json['adrun'] as String?,
        adrName: json['adrName'] as String?,
        adrClass: json['adrClass'] as String?,
        packingGroup: json['packingGroup'] as String?,
        tremcard: json['tremcard'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'adrun': adrUn,
        'adrName': adrName,
        'adrClass': adrClass,
        'packingGroup': packingGroup,
        'tremcard': tremcard,
      };
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
