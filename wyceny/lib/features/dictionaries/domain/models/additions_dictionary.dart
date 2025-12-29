class AdditionsDictionary {
  final double bafValue;
  final double tafValue;
  final double inflCorrectionValue;

  const AdditionsDictionary({
    required this.bafValue,
    required this.tafValue,
    required this.inflCorrectionValue,
  });

  factory AdditionsDictionary.fromJson(Map<String, dynamic> json) => AdditionsDictionary(
    bafValue: (json['bafValue'] as num).toDouble(),
    tafValue: (json['tafValue'] as num).toDouble(),
    inflCorrectionValue: (json['inflCorrectionValue'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'bafValue': bafValue,
    'tafValue': tafValue,
    'inflCorrectionValue': inflCorrectionValue,
  };
}
