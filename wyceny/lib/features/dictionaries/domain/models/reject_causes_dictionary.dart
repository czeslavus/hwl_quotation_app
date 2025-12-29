class RejectCausesDictionary {
  final int rejectCauseId;
  final String? rejectCauseName;

  const RejectCausesDictionary({
    required this.rejectCauseId,
    this.rejectCauseName,
  });

  factory RejectCausesDictionary.fromJson(Map<String, dynamic> json) => RejectCausesDictionary(
    rejectCauseId: (json['rejectCauseId'] as num).toInt(),
    rejectCauseName: json['rejectCauseName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'rejectCauseId': rejectCauseId,
    'rejectCauseName': rejectCauseName,
  };
}
