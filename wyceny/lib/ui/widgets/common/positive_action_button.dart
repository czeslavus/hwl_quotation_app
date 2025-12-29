import 'package:flutter/material.dart';

class PositiveActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  /// Tooltip (opcjonalny)
  final String? tooltip;

  /// Czy pokazywać podpis tekstowy obok ikony
  /// Domyślnie: true
  final bool showCaption;

  /// Kolor tła (domyślnie zielony – Material Green 600)
  final Color color;

  /// Wysokość przycisku
  final double height;

  const PositiveActionButton({
  super.key,
  required this.onPressed,
  required this.icon,
  required this.label,
  this.tooltip,
  this.showCaption = true,
  this.color = const Color(0xFF43A047), // Material Green 600
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

  if (tooltip != null && tooltip!.isNotEmpty) {
    button = Tooltip(
      message: tooltip!,
      child: button,
    );
  }

  return button;
}
}
