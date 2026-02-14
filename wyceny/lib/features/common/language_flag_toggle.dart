import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:wyceny/app/locale_controller.dart';

class LanguageFlagToggle extends StatelessWidget {
  final double size;

  const LanguageFlagToggle({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final lc = GetIt.I<LocaleController>();
    final systemLocale = Localizations.localeOf(context);

    return ListenableBuilder(
      listenable: lc,
      builder: (_, __) {
        final effectiveLocale = lc.locale ?? systemLocale;
        final code = effectiveLocale.languageCode;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FlagButton(
              size: size,
              flag: '🇵🇱',
              label: 'PL',
              selected: code == 'pl',
              onTap: () => lc.setLocale(const Locale('pl')),
            ),
            const SizedBox(width: 6),
            _FlagButton(
              size: size,
              flag: '🇬🇧',
              label: 'EN',
              selected: code == 'en',
              onTap: () => lc.setLocale(const Locale('en')),
            ),
          ],
        );
      },
    );
  }
}

class _FlagButton extends StatelessWidget {
  final double size;
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FlagButton({
    required this.size,
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected ? theme.colorScheme.primary : theme.dividerColor;
    final bgColor = selected
        ? theme.colorScheme.primary.withOpacity(0.08)
        : theme.colorScheme.surface;

    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            flag,
            style: TextStyle(fontSize: size),
          ),
        ),
      ),
    );
  }
}
