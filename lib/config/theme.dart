import 'package:flutter/material.dart';

class HumanNodeTheme {
  static const Color primary = Color(0xFFDA7756);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF06B6D4);
  static const Color surface = Color(0xFF0D0D0D);
  static const Color surfaceCard = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF232323);
  static const Color border = Color(0xFF2C2C2C);
  static const Color textPrimary = Color(0xFFF2F2F2);
  static const Color textSecondary = Color(0xFF8C8C8C);
  static const Color orbBlue = Color(0xFF4F8EF7);
  static const Color orbPurple = Color(0xFF8B5CF6);
  static const Color orbCyan = Color(0xFF06B6D4);

  static ThemeData get dark {
    final cs = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF1E1B4B),
      onPrimaryContainer: const Color(0xFFC7D2FE),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF1E1B4B),
      onSecondaryContainer: const Color(0xFFDDD6FE),
      tertiary: accent,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF0C2A36),
      onTertiaryContainer: const Color(0xFFA5F3FC),
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      errorContainer: const Color(0xFF3B0A0A),
      onErrorContainer: const Color(0xFFFCA5A5),
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceElevated,
      outline: border,
      outlineVariant: const Color(0xFF1E1E2E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(0, 48),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 0.5),
      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: textSecondary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get light => dark;
}
