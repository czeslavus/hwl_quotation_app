import 'package:flutter/material.dart';
import 'base_action_button.dart';

class PositiveActionButton extends StatelessWidget {
  const PositiveActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.tooltip,
    this.showCaption = true,
    this.height = 40,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
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

  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return BaseActionButton(
      onPressed: onPressed,
      icon: icon,
      label: label,
      tooltip: tooltip,
      showCaption: showCaption,
      height: height,
      iconSize: iconSize,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor ?? const Color(0xFF43A047), // Green 600
      hoverBackgroundColor: hoverBackgroundColor,
      foregroundColor: foregroundColor ?? Colors.white,
      disabledBackgroundColor: disabledBackgroundColor ?? const Color(0xFFBDBDBD),
      disabledForegroundColor: disabledForegroundColor ?? Colors.white,
    );
  }
}
