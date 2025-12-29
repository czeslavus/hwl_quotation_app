class InstructionCodeDictionary {
  final int instructionCodeId;
  final String? instructionCodeNr;
  final String? instructionCodeName;

  const InstructionCodeDictionary({
    required this.instructionCodeId,
    this.instructionCodeNr,
    this.instructionCodeName,
  });

  factory InstructionCodeDictionary.fromJson(Map<String, dynamic> json) => InstructionCodeDictionary(
    instructionCodeId: (json['instructionCodeId'] as num).toInt(),
    instructionCodeNr: json['instructionCodeNr'] as String?,
    instructionCodeName: json['instructionCodeName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'instructionCodeId': instructionCodeId,
    'instructionCodeNr': instructionCodeNr,
    'instructionCodeName': instructionCodeName,
  };
}
