import 'package:flutter/material.dart';

class DangerActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  /// Tooltip (jeśli null – tooltip nie jest wyświetlany)
  final String? tooltip;

  /// Czy pokazywać podpis tekstowy obok ikony
  /// Domyślnie: true
  final bool showCaption;

  /// Kolor tła przycisku (domyślnie czerwony – Material Red 700)
  final Color color;

  /// Wysokość przycisku
  final double height;

  const DangerActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.tooltip,
    this.showCaption = true,
    this.color = const Color(0xFFD32F2F), // Material Red 700
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    Widget button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(
          horizontal: showCaption ? 14 : 8,
        ),
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade400 : color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            if (showCaption) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );

    // Tooltip tylko jeśli podany
    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
