import 'package:flutter/material.dart';

class KhatwaTheme {
  static const Color primary      = Color(0xFF1D9E75);
  static const Color primaryDark  = Color(0xFF0F6E56);
  static const Color primaryLight = Color(0xFFE1F5EE);
  static const Color surface      = Color(0xFFF8FAF9);
  static const Color cardBg       = Colors.white;
  static const Color textPrimary  = Color(0xFF1A1A1A);
  static const Color textSecondary= Color(0xFF6B7280);
  static const Color textHint     = Color(0xFFB0B8C1);
  static const Color border       = Color(0xFFE5E7EB);

  // ── Light Theme ──
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: surface,
    cardColor: cardBg,
    dividerColor: border,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBg,
      selectedItemColor: primary,
      unselectedItemColor: textHint,
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primary : textHint),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? primary.withOpacity(0.4)
              : border),
    ),
  );

  // ── Dark Theme ──
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F1510),
    cardColor: const Color(0xFF1A2420),
    dividerColor: const Color(0xFF2A3830),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D1F1A),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1A2420),
      selectedItemColor: primary,
      unselectedItemColor: Colors.white.withOpacity(0.4),
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primary : Colors.grey),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? primary.withOpacity(0.4)
              : Colors.white12),
    ),
  );
}

// Extension لسهولة الوصول لألوان حسب الثيم الحالي
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get cardBg => isDark ? const Color(0xFF1A2420) : Colors.white;
  Color get surfaceBg => isDark ? const Color(0xFF0F1510) : const Color(0xFFF8FAF9);
  Color get borderColor => isDark ? const Color(0xFF2A3830) : const Color(0xFFE5E7EB);
  Color get textPrimary => isDark ? Colors.white.withOpacity(0.92) : const Color(0xFF1A1A1A);
  Color get textSecondary => isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF6B7280);
}
