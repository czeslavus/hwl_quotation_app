class ADRNameDictionary {
  final String? un;
  final String? name;
  final String? adrClass;
  final String? packingGroup;
  final String? tremcard;

  const ADRNameDictionary({
    this.un,
    this.name,
    this.adrClass,
    this.packingGroup,
    this.tremcard,
  });

  factory ADRNameDictionary.fromJson(Map<String, dynamic> json) => ADRNameDictionary(
    un: json['un'] as String?,
    name: json['name'] as String?,
    adrClass: json['class'] as String?,
    packingGroup: json['packingGroup'] as String?,
    tremcard: json['tremcard'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'un': un,
    'name': name,
    'class': adrClass,
    'packingGroup': packingGroup,
    'tremcard': tremcard,
  };
}
