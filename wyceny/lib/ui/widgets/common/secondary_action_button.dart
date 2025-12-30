import 'package:flutter/material.dart';
import 'base_action_button.dart';

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.tooltip,
    this.showCaption = true,
    this.height = 40,

    /// Można nadpisać kolory:
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,

    /// Można nadpisać border:
    this.borderColor,
    this.hoverBorderColor,

    this.borderRadius = 8,
    this.iconSize = 18,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final String? tooltip;
  final bool showCaption;
  final double height;

  final Color? backgroundColor;
  final Color? hoverBackgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;

  final Color? borderColor;
  final Color? hoverBorderColor;

  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final defaultBorder = BorderSide(color: borderColor ?? const Color(0xFFE0E0E0));

    return BaseActionButton(
      onPressed: onPressed,
      icon: icon,
      label: label,
      tooltip: tooltip,
      showCaption: showCaption,
      height: height,
      iconSize: iconSize,
      borderRadius: borderRadius,

      backgroundColor: backgroundColor ?? Colors.white,
      hoverBackgroundColor: hoverBackgroundColor ?? const Color(0xFFF5F5F5),
      foregroundColor: foregroundColor ?? Colors.black87,

      disabledBackgroundColor: disabledBackgroundColor ?? const Color(0xFFE0E0E0),
      disabledForegroundColor: disabledForegroundColor ?? Colors.grey,

      border: defaultBorder,
      hoverBorderColor: hoverBorderColor ?? const Color(0xFFBDBDBD),

      // dla secondary cień może być delikatniejszy; zostawiam true, bo ładnie wygląda
      enableHoverShadow: true,
    );
  }
}
