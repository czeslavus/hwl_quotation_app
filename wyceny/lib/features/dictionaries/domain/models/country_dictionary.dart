class CountryDictionary {
  static const Map<String, String> _nameToIso2 = {
    'albania': 'AL',
    'andorra': 'AD',
    'austria': 'AT',
    'belarus': 'BY',
    'belgium': 'BE',
    'bosnia and herzegovina': 'BA',
    'bulgaria': 'BG',
    'croatia': 'HR',
    'cyprus': 'CY',
    'czech republic': 'CZ',
    'czechia': 'CZ',
    'denmark': 'DK',
    'estonia': 'EE',
    'finland': 'FI',
    'france': 'FR',
    'germany': 'DE',
    'greece': 'GR',
    'hungary': 'HU',
    'iceland': 'IS',
    'ireland': 'IE',
    'italy': 'IT',
    'kosovo': 'XK',
    'latvia': 'LV',
    'liechtenstein': 'LI',
    'lithuania': 'LT',
    'luxembourg': 'LU',
    'malta': 'MT',
    'moldova': 'MD',
    'monaco': 'MC',
    'montenegro': 'ME',
    'netherlands': 'NL',
    'north macedonia': 'MK',
    'norway': 'NO',
    'poland': 'PL',
    'portugal': 'PT',
    'romania': 'RO',
    'russia': 'RU',
    'san marino': 'SM',
    'serbia': 'RS',
    'slovakia': 'SK',
    'slovenia': 'SI',
    'spain': 'ES',
    'sweden': 'SE',
    'switzerland': 'CH',
    'turkey': 'TR',
    'ukraine': 'UA',
    'united kingdom': 'GB',
    'uk': 'GB',
    'vatican city': 'VA',
  };

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
    final apiIso2 = (json['countryCode'] as String?)?.trim().toUpperCase();
    final iso2 = (apiIso2 != null && apiIso2.isNotEmpty)
        ? apiIso2
        : (resolveIso2?.call(id, name) ?? _fallbackIso2(id, name));

    return CountryDictionary(countryId: id, country: name, countryCode: iso2);
  }

  Map<String, dynamic> toJson() => {
    'countryId': countryId,
    'country': country,
    // EXT
    'countryCode': countryCode,
  };

  static String _fallbackIso2(int id, String? name) {
    final normalizedName = name?.trim().toLowerCase();
    if (normalizedName != null) {
      final fromName = _nameToIso2[normalizedName];
      if (fromName != null) return fromName;
    }
    if (id == 616) return 'PL';
    if (id == 276) return 'DE';
    if (id == 203) return 'CZ';
    return '??';
  }
}
