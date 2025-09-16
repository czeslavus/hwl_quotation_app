class QuotationItem {
  final int? id;
  final int quotationId;
  final int quantity;
  final int length;
  final int width;
  final int height;
  final int weight;
  final bool? stackability;
  final int? packaging;
  final double? packagingWeight;
  final double? cbm;
  final double? ldm;
  final double? ldmCbm;
  final double? longWeight;

  const QuotationItem({
    this.id,
    required this.quotationId,
    required this.quantity,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    this.stackability,
    this.packaging,
    this.packagingWeight,
    this.cbm,
    this.ldm,
    this.ldmCbm,
    this.longWeight,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) => QuotationItem(
    id: json['id'],
    quotationId: json['pricingId'],
    quantity: json['quantity'],
    length: json['length'],
    width: json['width'],
    height: json['height'],
    weight: json['weight'],
    stackability: json['stackability'],
    packaging: json['packaging'],
    packagingWeight: (json['packagingWeight'] as num?)?.toDouble(),
    cbm: (json['cbm'] as num?)?.toDouble(),
    ldm: (json['ldm'] as num?)?.toDouble(),
    ldmCbm: (json['ldmCbm'] as num?)?.toDouble(),
    longWeight: (json['longWeight'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'pricingId': quotationId,
    'quantity': quantity,
    'length': length,
    'width': width,
    'height': height,
    'weight': weight,
    'stackability': stackability,
    'packaging': packaging,
    'packagingWeight': packagingWeight,
    'cbm': cbm,
    'ldm': ldm,
    'ldmCbm': ldmCbm,
    'longWeight': longWeight,
  };
}
