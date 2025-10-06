class OrderItem {
  int? qty;
  String? packType;       // np. "EUR-1 (1,2x0,8)"
  double? lengthCm;       // L
  double? widthCm;        // W
  double? heightCm;       // H
  double? weightKg;       // rzeczywista
  bool adr;

  OrderItem({
    this.qty,
    this.packType,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.weightKg,
    this.adr = false,
  });

  /// CBM = qty * (L/100) * (W/100) * (H/100)
  double get cbm {
    final q = (qty ?? 0);
    final l = (lengthCm ?? 0) / 100.0;
    final w = (widthCm ?? 0) / 100.0;
    final h = (heightCm ?? 0) / 100.0;
    return q * l * w * h;
  }

  OrderItem copyWith({
    int? qty,
    String? packType,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    double? weightKg,
    bool? adr,
  }) {
    return OrderItem(
      qty: qty ?? this.qty,
      packType: packType ?? this.packType,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      adr: adr ?? this.adr,
    );
  }

  // Wygodny „starter” pod przycisk +
  factory OrderItem.example() => OrderItem(
    qty: 1,
    packType: "EUR-1 (1,2x0,8)",
    lengthCm: 120,
    widthCm: 80,
    heightCm: 80,
    weightKg: 200,
    adr: false,
  );
}
