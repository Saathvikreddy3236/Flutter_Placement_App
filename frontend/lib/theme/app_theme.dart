import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryOrange = Color(0xFFC75A00);
  static const Color deepOrange = Color(0xFF8C3900);
  static const Color softOrange = Color(0xFFFFE8D1);
  static const Color warmCanvas = Color(0xFFFFF8F1);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryOrange,
      primary: primaryOrange,
      secondary: const Color(0xFFE1A45F),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: warmCanvas,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 31,
        fontWeight: FontWeight.w700,
        color: Color(0xFF3E220F),
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF3E220F),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF3E220F),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3E220F),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF6D4C36),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF6D4C36),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF3E220F),
      elevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: deepOrange,
        side: const BorderSide(color: Color(0xFFE8B98C)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFF1DDCC)),
      ),
      elevation: 2,
      shadowColor: const Color(0x1A7A4A24),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFCF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFFD6B3), width: 1.1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFFD6B3), width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryOrange, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF8C5A39)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}
