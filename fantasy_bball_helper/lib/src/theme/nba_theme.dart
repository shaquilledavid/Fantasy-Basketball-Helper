import "package:flutter/material.dart";

class NbaTheme {
  static const Color seed = Color(0xFF1D428A); // NBA blue
  static const Color accent = Color(0xFFC9082A); // NBA red
  static const Color court = Color(0xFFE8D5B5); // Hardwood court
  static const Color _lightBackground = Color(0xFFF5F5F7);
  static const Color _darkBackground = Color(0xFF121218);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: const Color(0xFFFFFFFF),
      primary: seed,
      secondary: accent,
    );

    return _base(
      scheme: scheme,
      brightness: Brightness.light,
      backgroundColor: _lightBackground,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: const Color(0xFF1C1C24),
      primary: const Color(0xFF5B8DEF),
      secondary: const Color(0xFFFF4D6A),
    );

    return _base(
      scheme: scheme,
      brightness: Brightness.dark,
      backgroundColor: _darkBackground,
    );
  }

  static ThemeData _base({
    required ColorScheme scheme,
    required Brightness brightness,
    required Color backgroundColor,
  }) {
    const radius = 16.0;
    final borderRadius = BorderRadius.circular(radius);

    final textTheme = Typography.material2021().black.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface.withValues(alpha: 0.92),
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        color: scheme.surface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface.withValues(alpha: 0.92),
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
