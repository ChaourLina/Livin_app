import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2C4251);
  static const Color silver = Color(0xFFC1C1C1);
  static const Color background = Color(0xFFF4F5F6);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: primary).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: silver,
      onSecondary: primary,
      secondaryContainer: silver,
      onSecondaryContainer: primary,
      surface: Colors.white,
      surfaceTint: Colors.transparent,
      outline: silver,
      outlineVariant: silver,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: silver),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: silver,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.white,
        side: BorderSide(color: silver),
        shape: StadiumBorder(),
      ),
    );
  }
}