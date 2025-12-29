class ADRPackageUnitTypeDictionary {
  final String? packageUnitTypeNR;
  final String? packageUnitTypeName;

  const ADRPackageUnitTypeDictionary({
    this.packageUnitTypeNR,
    this.packageUnitTypeName,
  });

  factory ADRPackageUnitTypeDictionary.fromJson(Map<String, dynamic> json) => ADRPackageUnitTypeDictionary(
    packageUnitTypeNR: json['packageUnitTypeNR'] as String?,
    packageUnitTypeName: json['packageUnitTypeName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'packageUnitTypeNR': packageUnitTypeNR,
    'packageUnitTypeName': packageUnitTypeName,
  };
}
