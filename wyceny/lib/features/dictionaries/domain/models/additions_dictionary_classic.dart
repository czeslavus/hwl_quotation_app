class AdditionsDictionaryClassic {
  final String? type;
  final double? value;

  const AdditionsDictionaryClassic({
    this.type,
    this.value,
  });

  factory AdditionsDictionaryClassic.fromJson(Map<String, dynamic> json) => AdditionsDictionaryClassic(
    type: json['type'] as String?,
    value: (json['value'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
  };
}
