class RejectModel {
  final int quotationId;
  final String rejectCause;
  const RejectModel({required this.quotationId, required this.rejectCause});
  Map<String, dynamic> toJson() => {
    'pricingId': quotationId,
    'rejectCause': rejectCause,
  };
}
