class LoadUnitDictionary {
  final int loadUnitTypeId;
  final String? loadUnitTypeNr;
  final String? loadUnitTypeName;

  const LoadUnitDictionary({
    required this.loadUnitTypeId,
    this.loadUnitTypeNr,
    this.loadUnitTypeName,
  });

  factory LoadUnitDictionary.fromJson(Map<String, dynamic> json) => LoadUnitDictionary(
    loadUnitTypeId: (json['loadUnitTypeId'] as num).toInt(),
    loadUnitTypeNr: json['loadUnitTypeNr'] as String?,
    loadUnitTypeName: json['loadUnitTypeName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'loadUnitTypeId': loadUnitTypeId,
    'loadUnitTypeNr': loadUnitTypeNr,
    'loadUnitTypeName': loadUnitTypeName,
  };
}
