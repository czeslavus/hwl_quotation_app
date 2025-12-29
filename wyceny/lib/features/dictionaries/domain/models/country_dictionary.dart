class CountryDictionary {
  /// API: countryId
  final int countryId;

  /// API: country
  final String? country;

  /// EXT: ISO2 (np. "PL", "DE") – nie ma w API, ale chcesz mieć w appce
  final String countryCode;

  const CountryDictionary({
    required this.countryId,
    this.country,
    required this.countryCode,
  });

  factory CountryDictionary.fromJson(
      Map<String, dynamic> json, {
        String Function(int countryId, String? country)? resolveIso2,
      }) {
    final id = (json['countryId'] as num).toInt();
    final name = json['country'] as String?;
    final iso2 = resolveIso2?.call(id, name) ?? _fallbackIso2(id, name);

    return CountryDictionary(
      countryId: id,
      country: name,
      countryCode: iso2,
    );
  }

  Map<String, dynamic> toJson() => {
    'countryId': countryId,
    'country': country,
    // EXT
    'countryCode': countryCode,
  };

  static String _fallbackIso2(int id, String? name) {
    // Minimalny sensowny fallback (możesz rozbudować lub podmienić resolverem)
    if (id == 616 || (name?.toLowerCase() == 'poland')) return 'PL';
    if (id == 276 || (name?.toLowerCase() == 'germany')) return 'DE';
    if (id == 203 || (name?.toLowerCase() == 'czechia')) return 'CZ';
    return '??';
  }
}
