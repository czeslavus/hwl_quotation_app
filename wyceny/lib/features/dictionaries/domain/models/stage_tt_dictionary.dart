class StageTTDictionary {
  final String? ttStateNr;
  final String? tsStateName;

  const StageTTDictionary({
    this.ttStateNr,
    this.tsStateName,
  });

  factory StageTTDictionary.fromJson(Map<String, dynamic> json) => StageTTDictionary(
    ttStateNr: json['ttStateNr'] as String?,
    tsStateName: json['tsStateName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'ttStateNr': ttStateNr,
    'tsStateName': tsStateName,
  };
}

