import 'package:flutter/material.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/features/preferences/ui/widgets/language_setting_tile.dart';
import 'package:wyceny/features/common/screen_frame.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return ScreenFrame(
      title: t.nav_settings, // lub dowolny tytuł
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          LanguageSettingTile(),
          // tutaj możesz dodać kolejne kafelki ustawień
        ],
      ),
    );
  }
}
