// lib/app/locale_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale'; // np. "pl", "en", "de" lub "" (system)

class LocaleController extends ChangeNotifier {
  Locale? _locale; // null => użyj języka systemowego
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    _locale = (code == null || code.isEmpty) ? null : Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale? l) async {
    _locale = l;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, l?.languageCode ?? '');
    notifyListeners();
  }
}
