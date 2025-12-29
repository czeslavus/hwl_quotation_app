class StatusesDictionary {
  final int statusId;
  final String? name;

  const StatusesDictionary({
    required this.statusId,
    this.name,
  });

  factory StatusesDictionary.fromJson(Map<String, dynamic> json) => StatusesDictionary(
    statusId: (json['statusId'] as num).toInt(),
    name: json['name'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'statusId': statusId,
    'name': name,
  };
}
