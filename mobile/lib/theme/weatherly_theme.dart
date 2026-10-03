import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'weatherly_palette.dart';
import 'weatherly_responsive.dart';

abstract final class WeatherlyColors {
  static const ink = Color(0xFF1E1B2B);
  static const muted = Color(0xFF6F6A8F);
  static const border = Color(0xFFD9D2E8);
  static const lavenderLight = Color(0xFFF7F3FF);
  static const lavenderMid = Color(0xFFE8E1F8);
  static const lavenderDeep = Color(0xFFD8D2F5);
  static const purpleDeep = Color(0xFF5B21B6);
  static const purpleBright = Color(0xFF7C3AED);
  static const purpleBorder = Color(0xFF8B5CF6);
  static const gold = Color(0xFFFDE68A);
  static const insightFooter = Color(0xFFE9D5FF);
  static const indigoBrand = Color(0xFF4F46E5);
  static const cityCardTitle = Color(0xFF141B2B);
  static const cityCardSub = Color(0xFF494552);
  static const tempAmber = Color(0xFFF59E0B);
  static const surfaceBorder = Color(0xFFE7E1F5);
}

abstract final class WeatherlyTheme {
  static ThemeData lightTheme() => _theme(WeatherlyPalette.light, Brightness.light);

  static ThemeData darkTheme() => _theme(WeatherlyPalette.dark, Brightness.dark);

  static ThemeData _theme(WeatherlyPalette palette, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: WeatherlyColors.purpleBright,
        brightness: brightness,
        surface: palette.surface0,
      ),
    );
    final inter = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: palette.ink,
      displayColor: palette.ink,
    );
    return base.copyWith(
      textTheme: inter,
      scaffoldBackgroundColor: palette.surface0,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.topBarStart,
        foregroundColor: palette.ink,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.cardStart,
        contentTextStyle: TextStyle(color: palette.ink),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: palette.onAccent,
      ),
    );
  }

  static LinearGradient get purpleCard => const LinearGradient(
        colors: [WeatherlyColors.purpleDeep, WeatherlyColors.purpleBright],
      );

  static List<BoxShadow> get purpleShadow => [
        BoxShadow(
          color: WeatherlyColors.purpleDeep.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get purpleShadowTight => [
        BoxShadow(
          color: WeatherlyColors.purpleDeep.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: WeatherlyColors.ink.withValues(alpha: 0.07),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];

  static TextStyle sectionLabel(BuildContext context) =>
      context.weatherly.sectionLabel();
}

BoxDecoration weatherlyGlassDecoration({
  required BuildContext context,
  bool purple = false,
  bool tightPurpleShadow = false,
  double? radius,
}) {
  final lay = context.weatherly;
  final p = context.palette;
  final r = radius ?? lay.radiusS;
  return BoxDecoration(
    gradient: purple ? p.accentGradient : p.glassCard,
    borderRadius: BorderRadius.circular(r),
    border: Border.all(
      color: purple ? p.accentBorder : p.border,
    ),
    boxShadow: purple
        ? (tightPurpleShadow ? WeatherlyTheme.purpleShadowTight : WeatherlyTheme.purpleShadow)
        : p.glassShadow,
  );
}
