class QuotationItem {
  /// API: itemId (nullable)
  final int? itemId;

  /// UI/API: adr (w API bywa nullable, w UI trzymamy jako bool)
  ///
  /// Wymaganie: ikona ADR w wierszu (szara gdy false, czerwona gdy true).
  final bool adr;

  /// API: quantity/length/width/height/weight (required)
  final int quantity;
  final int length;
  final int width;
  final int height;
  final int weight;

  /// API: packaging (nullable)
  final int? packaging;

  /// API: packagingWeight/cbm/ldm/ldmCbm/longWeight (nullable)
  final double? packagingWeight;
  final double? cbm;
  final double? ldm;
  final double? ldmCbm;
  final double? longWeight;

  const QuotationItem({
    this.itemId,
    this.adr = false,
    required this.quantity,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    this.packaging,
    this.packagingWeight,
    this.cbm,
    this.ldm,
    this.ldmCbm,
    this.longWeight,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) => QuotationItem(
    itemId: json['itemId'] as int?,
    adr: (json['adr'] as bool?) ?? false,
    quantity: json['quantity'] as int,
    length: json['length'] as int,
    width: json['width'] as int,
    height: json['height'] as int,
    weight: json['weight'] as int,
    packaging: json['packaging'] as int?,
    packagingWeight: (json['packagingWeight'] as num?)?.toDouble(),
    cbm: (json['cbm'] as num?)?.toDouble(),
    ldm: (json['ldm'] as num?)?.toDouble(),
    ldmCbm: (json['ldmCbm'] as num?)?.toDouble(),
    longWeight: (json['longWeight'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'adr': adr,
    'quantity': quantity,
    'length': length,
    'width': width,
    'height': height,
    'weight': weight,
    'packaging': packaging,
    'packagingWeight': packagingWeight,
    'cbm': cbm,
    'ldm': ldm,
    'ldmCbm': ldmCbm,
    'longWeight': longWeight,
  };

  QuotationItem copyWith({
    int? itemId,
    bool? adr,
    int? quantity,
    int? length,
    int? width,
    int? height,
    int? weight,
    int? packaging,
    double? packagingWeight,
    double? cbm,
    double? ldm,
    double? ldmCbm,
    double? longWeight,
    bool clearPackaging = false,
  }) {
    return QuotationItem(
      itemId: itemId ?? this.itemId,
      adr: adr ?? this.adr,
      quantity: quantity ?? this.quantity,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      packaging: clearPackaging ? null : (packaging ?? this.packaging),
      packagingWeight: packagingWeight ?? this.packagingWeight,
      cbm: cbm ?? this.cbm,
      ldm: ldm ?? this.ldm,
      ldmCbm: ldmCbm ?? this.ldmCbm,
      longWeight: longWeight ?? this.longWeight,
    );
  }
}
