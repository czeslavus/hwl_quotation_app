import 'package:flutter/material.dart';

/// Web-first, "clean table" theme inspired by the provided screenshots:
/// - light grey page background
/// - white surfaces/cards
/// - subtle borders instead of heavy elevation
/// - deep blue as the primary brand color
/// - plenty of spacing and readable typography
class AppColors {
  static const brand = Color(0xFF004C97);
  static const brandHover = Color(0xFF0B5AA3);

  static const link = Color(0xFF0B63CE);
  static const pageBg = Color(0xFFF3F4F6);
  static const surface = Colors.white;
  static const border = Color(0xFFE5E7EB);

  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);

  static const success = Color(0xFF1F9D55);
  static const danger = Color(0xFFE53935);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: false, // closer to the screenshot look
      brightness: Brightness.light,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.pageBg,
      primaryColor: AppColors.brand,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.brand,
        secondary: AppColors.brand,
        surface: AppColors.surface,
        onSurface: AppColors.text,
      ),

      // AppBar: white background (divider handled best in scaffold/layout)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        iconTheme: IconThemeData(color: AppColors.text),
      ),

      // Typography (keep it simple, readable, web-like)
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
        titleMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: AppColors.text,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          color: AppColors.muted,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Cards/panels: white + subtle border (most of the "table containers")
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Inputs: underline style like in the screenshots
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        filled: false,
        labelStyle: TextStyle(color: AppColors.muted, fontSize: 12),
        hintStyle: TextStyle(color: AppColors.muted),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.brand, width: 2),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.link,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      // Icon buttons: keep neutral (no global red backgrounds)
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.muted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.brand;
          return Colors.white;
        }),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),

      // DataTable: header bold, subtle row dividers, comfortable height
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(Colors.white),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.text,
          fontSize: 13,
        ),
        dataTextStyle: const TextStyle(
          color: AppColors.text,
          fontSize: 13,
        ),
        dividerThickness: 1,
      ),

      // Tabs (if used): blue underline, grey inactive
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.brand,
        unselectedLabelColor: Color(0xFF9CA3AF),
        indicatorColor: AppColors.brand,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),

      // Dialogs: white, subtle shadow
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      // NavigationRail (desktop/web): blue background like requested
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.brand,
        elevation: 2,
        indicatorColor: AppColors.brandHover,

        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 22,
        ),
        unselectedIconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.75),
          size: 22,
        ),

        selectedLabelTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.white.withOpacity(0.78),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
