// lib/core/i18n/country_localizer.dart
import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';

class CountryLocalizer {
  /// mapuje EN → PL (Europa). Klucze w dokładnym brzmieniu jak z backendu (EN).
  static final Map<String, String> _enToPl = {
    "Albania": "Albania",
    "Andorra": "Andora",
    "Austria": "Austria",
    "Belarus": "Białoruś",
    "Belgium": "Belgia",
    "Bosnia and Herzegovina": "Bośnia i Hercegowina",
    "Bulgaria": "Bułgaria",
    "Croatia": "Chorwacja",
    "Cyprus": "Cypr",
    "Czech Republic": "Czechy",
    "Denmark": "Dania",
    "Estonia": "Estonia",
    "Finland": "Finlandia",
    "France": "Francja",
    "Germany": "Niemcy",
    "Greece": "Grecja",
    "Hungary": "Węgry",
    "Iceland": "Islandia",
    "Ireland": "Irlandia",
    "Italy": "Włochy",
    "Kosovo": "Kosowo",
    "Latvia": "Łotwa",
    "Liechtenstein": "Liechtenstein",
    "Lithuania": "Litwa",
    "Luxembourg": "Luksemburg",
    "Malta": "Malta",
    "Moldova": "Mołdawia",
    "Monaco": "Monako",
    "Montenegro": "Czarnogóra",
    "Netherlands": "Niderlandy",
    "North Macedonia": "Macedonia Północna",
    "Norway": "Norwegia",
    "Poland": "Polska",
    "Portugal": "Portugalia",
    "Romania": "Rumunia",
    "Russia": "Rosja",
    "San Marino": "San Marino",
    "Serbia": "Serbia",
    "Slovakia": "Słowacja",
    "Slovenia": "Słowenia",
    "Spain": "Hiszpania",
    "Sweden": "Szwecja",
    "Switzerland": "Szwajcaria",
    "Ukraine": "Ukraina",
    "United Kingdom": "Wielka Brytania",
    "Vatican City": "Watykan",
    // terytoria zależne / specjalne:
    "Åland Islands": "Wyspy Alandzkie",
    "Gibraltar": "Gibraltar",
    "Guernsey": "Guernsey",
    "Jersey": "Jersey",
    "Isle of Man": "Wyspa Man",
    // aliasy spotykane w danych:
    "Czechia": "Czechy",
    "UK": "Wielka Brytania",
    "Republic of Moldova": "Mołdawia",
  };

  /// Zwraca nazwę zależną od locale. Dla 'pl' zwraca tłumaczenie, w pozostałych językach — oryginał EN.
  static String localize(String? english, BuildContext context) {
    if (english == null || english.trim().isEmpty) return "";
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    if (lang == 'pl') {
      // dopasowanie case-insensitive/aliasów
      final hit = _enToPl.entries.firstWhereOrNull(
            (e) => e.key.toLowerCase() == english.toLowerCase(),
      );
      return hit?.value ?? english;
    }
    return english; // EN i inne: bez zmian
  }
}
