import 'package:flutter/material.dart';

class BaseActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  /// Jeśli null/puste -> tooltip = label. Jeśli label też puste -> brak tooltipa.
  final String? tooltip;

  /// Domyślnie: true (ikona + napis). false => tylko ikona.
  final bool showCaption;

  /// Wysokość przycisku
  final double height;

  /// Rozmiar ikony
  final double iconSize;

  /// Zaokrąglenie
  final double borderRadius;

  /// Padding poziomy (gdy showCaption=true/false)
  final double paddingWithCaption;
  final double paddingIconOnly;

  /// Kolory tła i treści
  /// - backgroundColor: kolor normalny
  /// - hoverBackgroundColor: kolor na hover (jeśli null -> liczymy z opacity)
  /// - disabledBackgroundColor: kolor disabled
  ///
  /// - foregroundColor: kolor ikony/tekstu
  /// - disabledForegroundColor: kolor ikony/tekstu disabled
  final Color backgroundColor;
  final Color? hoverBackgroundColor;
  final Color disabledBackgroundColor;

  final Color foregroundColor;
  final Color disabledForegroundColor;

  /// Obramowanie (opcjonalne) – przydaje się np. dla secondary/white
  final BorderSide? border;
  final Color? hoverBorderColor;

  /// Cień na hover
  final bool enableHoverShadow;

  const BaseActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.tooltip,
    this.showCaption = true,
    this.height = 40,
    this.iconSize = 18,
    this.borderRadius = 8,
    this.paddingWithCaption = 14,
    this.paddingIconOnly = 8,
    this.hoverBackgroundColor,
    this.disabledBackgroundColor = const Color(0xFFBDBDBD),
    this.disabledForegroundColor = Colors.white,
    this.border,
    this.hoverBorderColor,
    this.enableHoverShadow = true,
  });

  @override
  State<BaseActionButton> createState() => _BaseActionButtonState();
}

class _BaseActionButtonState extends State<BaseActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    final effectiveTooltip = (widget.tooltip != null && widget.tooltip!.isNotEmpty)
        ? widget.tooltip!
        : widget.label;

    final Color bg = disabled
        ? widget.disabledBackgroundColor
        : (_hovered
        ? (widget.hoverBackgroundColor ?? widget.backgroundColor.withOpacity(0.85))
        : widget.backgroundColor);

    final Color fg = disabled ? widget.disabledForegroundColor : widget.foregroundColor;

    final BorderSide? effectiveBorder = widget.border == null
        ? null
        : (disabled
        ? widget.border
        : (_hovered && widget.hoverBorderColor != null
        ? widget.border!.copyWith(color: widget.hoverBorderColor)
        : widget.border));

    Widget button = MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.height,
          padding: EdgeInsets.symmetric(
            horizontal: widget.showCaption ? widget.paddingWithCaption : widget.paddingIconOnly,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: effectiveBorder == null ? null : Border.fromBorderSide(effectiveBorder),
            boxShadow: (!disabled && _hovered && widget.enableHoverShadow)
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: fg, size: widget.iconSize),
              if (widget.showCaption) ...[
                const SizedBox(width: 8),
                Text(widget.label, style: TextStyle(color: fg)),
              ],
            ],
          ),
        ),
      ),
    );

    // tooltip domyślnie = label, ale jeśli label puste -> brak tooltipa
    return effectiveTooltip.isNotEmpty ? Tooltip(message: effectiveTooltip, child: button) : button;
  }
}
