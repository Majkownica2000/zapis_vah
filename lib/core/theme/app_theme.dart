import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _amber = Color(0xFFF97316);
  static const _teal = Color(0xFF0D9488);
  static const _green = Color(0xFF22C55E);

  static ThemeData light() {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _amber,
      onPrimary: Colors.white,
      secondary: _teal,
      onSecondary: Colors.white,
      tertiary: _green,
      onTertiary: Colors.white,
      error: const Color(0xFFDC2626),
      onError: Colors.white,
      surface: const Color(0xFFF8F9FA),
      onSurface: const Color(0xFF1A1A2E),
      surfaceContainerHighest: const Color(0xFFF1F3F5),
      outline: const Color(0xFFD1D5DB),
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        isDense: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _amber,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: _amber.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFFB923C),
      onPrimary: const Color(0xFF1A1A2E),
      secondary: const Color(0xFF2DD4BF),
      onSecondary: const Color(0xFF1A1A2E),
      tertiary: const Color(0xFF4ADE80),
      onTertiary: const Color(0xFF1A1A2E),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF1A1A2E),
      surface: const Color(0xFF0F1115),
      onSurface: const Color(0xFFE4E4E7),
      surfaceContainerHighest: const Color(0xFF1A1D23),
      outline: const Color(0xFF3F3F46),
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Color(0xFF0F1115),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFF1A1D23),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        isDense: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFB923C),
          foregroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: const Color(0xFFFB923C).withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
