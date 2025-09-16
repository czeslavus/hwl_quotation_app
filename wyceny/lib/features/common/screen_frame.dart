import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wyceny/l10n/app_localizations.dart';

class ScreenFrame extends StatelessWidget {
  final String title;
  const ScreenFrame({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;

    final isPhone = width < 600;

    return Scaffold(
      appBar: (!isPhone)
          ? AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      )
          : null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(t.frame_placeholder(title)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: () => context.push('details'),
                  child: Text(t.frame_exampleSubscreen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

