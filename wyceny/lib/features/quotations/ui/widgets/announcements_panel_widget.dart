import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnnouncementsPanel extends StatefulWidget {
  final Widget header;
  final Widget body;
  const AnnouncementsPanel({super.key, required this.header, required this.body});

  @override
  State<AnnouncementsPanel> createState() => _AnnouncementsPanelState();
}

class _AnnouncementsPanelState extends State<AnnouncementsPanel>
    with TickerProviderStateMixin {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nagłówek – klikalny, przełącza rozwinięcie
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  // Treść nagłówka
                  Expanded(
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyLarge!,
                      child: widget.header,
                    ),
                  ),
                  // Strzałka z animacją obrotu
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0, // 0.5 obrotu = strzałka w górę
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),

          // Treść rozwijana – bez własnego przewijania
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: widget.body,
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
