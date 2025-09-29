class RejectModel {
  final int quotationId;
  final String reason;
  const RejectModel({required this.quotationId, required this.reason});
  Map<String, dynamic> toJson() => {
    'pricingId': quotationId,
    'rejectCause': reason,
  };
}
