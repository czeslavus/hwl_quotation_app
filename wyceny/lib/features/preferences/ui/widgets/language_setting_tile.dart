import 'package:wyceny/app/locale_controller.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

class LanguageSettingTile extends StatefulWidget {
  const LanguageSettingTile({super.key});
  @override
  State<LanguageSettingTile> createState() => _LanguageSettingTileState();
}

class _LanguageSettingTileState extends State<LanguageSettingTile> {
  final lc = GetIt.I<LocaleController>();

  String _labelFor(Locale? l, AppLocalizations t) {
    if (l == null) return t.settings_lang_system; // np. "System language"
    switch (l.languageCode) {
      case 'pl': return 'Polski';
      case 'en': return 'English';
      case 'de': return 'Deutsch';
      default:   return l.languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locales = AppLocalizations.supportedLocales;

    return ListenableBuilder(
      listenable: lc,
      builder: (_, __) {
        return ListTile(
          title: Text(t.settings_language),
          subtitle: Text(_labelFor(lc.locale, t)),
          trailing: DropdownButton<Locale?>(
            value: lc.locale, // null => system
            items: [
              DropdownMenuItem(value: null, child: Text(_labelFor(null, t))),
              ...locales.map((l) => DropdownMenuItem(
                value: l,
                child: Text(_labelFor(l, t)),
              )),
            ],
            onChanged: (value) => lc.setLocale(value),
          ),
        );
      },
    );
  }
}
