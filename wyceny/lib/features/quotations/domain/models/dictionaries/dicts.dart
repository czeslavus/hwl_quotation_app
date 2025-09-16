class Addition {
  final int id;
  final String? type;
  final double? value;
  const Addition({required this.id, this.type, this.value});
  factory Addition.fromJson(Map<String, dynamic> json) => Addition(
    id: json['id'], type: json['type'], value: (json['value'] as num?)?.toDouble(),
  );
}

class Country {
  final int id;
  final String? country;
  const Country({required this.id, this.country});
  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(id: json['id'], country: json['country']);
}

class ServiceDict {
  final int id;
  final String? name;
  final String? description;
  const ServiceDict({required this.id, this.name, this.description});
  factory ServiceDict.fromJson(Map<String, dynamic> json) => ServiceDict(
    id: json['id'], name: json['name'], description: json['description'],
  );
}

class StatusDict {
  final int id;
  final String? name;
  const StatusDict({required this.id, this.name});
  factory StatusDict.fromJson(Map<String, dynamic> json) =>
      StatusDict(id: json['id'], name: json['name']);
}
