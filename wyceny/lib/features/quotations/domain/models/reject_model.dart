class RejectModel {
  /// API: quotationId (required)
  final int quotationId;

  /// API: rejectCauseId (required)
  final int rejectCauseId;

  /// API: rejectCause (nullable, opcjonalny opis)
  final String? rejectCause;

  const RejectModel({
    required this.quotationId,
    required this.rejectCauseId,
    this.rejectCause,
  });

  Map<String, dynamic> toJson() => {
    'quotationId': quotationId,
    'rejectCauseId': rejectCauseId,
    'rejectCause': rejectCause,
  };
}
