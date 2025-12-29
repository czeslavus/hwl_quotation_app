class ServicesDictionary {
  final int serviceId;
  final String? name;
  final String? description;

  const ServicesDictionary({
    required this.serviceId,
    this.name,
    this.description,
  });

  factory ServicesDictionary.fromJson(Map<String, dynamic> json) => ServicesDictionary(
    serviceId: (json['serviceId'] as num).toInt(),
    name: json['name'] as String?,
    description: json['description'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'serviceId': serviceId,
    'name': name,
    'description': description,
  };
}
