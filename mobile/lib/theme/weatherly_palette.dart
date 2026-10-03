import 'package:flutter/material.dart';

import 'weatherly_theme.dart';

@immutable
class WeatherlyPalette extends ThemeExtension<WeatherlyPalette> {
  const WeatherlyPalette({
    required this.ink,
    required this.muted,
    required this.border,
    required this.surface0,
    required this.surface1,
    required this.surface2,
    required this.cardStart,
    required this.cardEnd,
    required this.topBarStart,
    required this.topBarEnd,
    required this.citiesPageTop,
    required this.citiesPageBottom,
    required this.cityCardTitle,
    required this.cityCardSub,
    required this.inputFill,
    required this.shadowBase,
    required this.heroShellStart,
    required this.heroShellMid,
    required this.heroShellEnd,
    required this.brandIndigo,
    required this.accent,
    required this.accentBorder,
    required this.accentDeep,
    required this.gold,
    required this.insightFooter,
    required this.tempAmber,
    required this.onAccent,
    required this.progressTrack,
    required this.heroTempGradientEnd,
  });

  final Color ink;
  final Color muted;
  final Color border;
  final Color surface0;
  final Color surface1;
  final Color surface2;
  final Color cardStart;
  final Color cardEnd;
  final Color topBarStart;
  final Color topBarEnd;
  final Color citiesPageTop;
  final Color citiesPageBottom;
  final Color cityCardTitle;
  final Color cityCardSub;
  final Color inputFill;
  final Color shadowBase;
  final Color heroShellStart;
  final Color heroShellMid;
  final Color heroShellEnd;
  final Color brandIndigo;
  final Color accent;
  final Color accentBorder;
  final Color accentDeep;
  final Color gold;
  final Color insightFooter;
  final Color tempAmber;
  final Color onAccent;
  final Color progressTrack;
  final Color heroTempGradientEnd;

  LinearGradient get accentGradient => LinearGradient(
        colors: [accentDeep, accent],
      );

  LinearGradient get pageBackground => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [surface0, surface1, surface2],
        stops: const [0, 0.58, 1],
      );

  LinearGradient get citiesPageBackground => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [citiesPageTop, citiesPageBottom],
      );

  LinearGradient get topBarGradient => LinearGradient(
        colors: [topBarStart, topBarEnd],
      );

  LinearGradient get glassCard => LinearGradient(
        colors: [cardStart, cardEnd],
      );

  LinearGradient get navBarGradient => LinearGradient(
        colors: [topBarStart, topBarEnd],
      );

  List<BoxShadow> get glassShadow => [
        BoxShadow(
          color: shadowBase.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: shadowBase.withValues(alpha: 0.12),
          blurRadius: 40,
          offset: const Offset(0, 18),
        ),
      ];

  List<BoxShadow> get navShadow => [
        BoxShadow(
          color: shadowBase.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, -4),
        ),
      ];

  static const light = WeatherlyPalette(
    ink: WeatherlyColors.ink,
    muted: WeatherlyColors.muted,
    border: WeatherlyColors.border,
    surface0: WeatherlyColors.lavenderLight,
    surface1: WeatherlyColors.lavenderMid,
    surface2: WeatherlyColors.lavenderDeep,
    cardStart: Colors.white,
    cardEnd: WeatherlyColors.lavenderLight,
    topBarStart: WeatherlyColors.lavenderLight,
    topBarEnd: WeatherlyColors.lavenderMid,
    citiesPageTop: Color(0xFFFCFBFF),
    citiesPageBottom: Color(0xFFF4EEFF),
    cityCardTitle: WeatherlyColors.cityCardTitle,
    cityCardSub: WeatherlyColors.cityCardSub,
    inputFill: Colors.white,
    shadowBase: WeatherlyColors.ink,
    heroShellStart: WeatherlyColors.lavenderLight,
    heroShellMid: WeatherlyColors.lavenderMid,
    heroShellEnd: WeatherlyColors.lavenderDeep,
    brandIndigo: WeatherlyColors.indigoBrand,
    accent: WeatherlyColors.purpleBright,
    accentBorder: WeatherlyColors.purpleBorder,
    accentDeep: WeatherlyColors.purpleDeep,
    gold: WeatherlyColors.gold,
    insightFooter: WeatherlyColors.insightFooter,
    tempAmber: WeatherlyColors.tempAmber,
    onAccent: Colors.white,
    progressTrack: WeatherlyColors.surfaceBorder,
    heroTempGradientEnd: Color(0xFF4C1D95),
  );

  static const dark = WeatherlyPalette(
    ink: Color(0xFFF3F0FF),
    muted: Color(0xFF9D97B8),
    border: Color(0xFF3D3654),
    surface0: Color(0xFF0F0D14),
    surface1: Color(0xFF161320),
    surface2: Color(0xFF1E1A28),
    cardStart: Color(0xFF2A2438),
    cardEnd: Color(0xFF221E30),
    topBarStart: Color(0xFF161320),
    topBarEnd: Color(0xFF1E1A28),
    citiesPageTop: Color(0xFF12101A),
    citiesPageBottom: Color(0xFF1A1625),
    cityCardTitle: Color(0xFFF3F0FF),
    cityCardSub: Color(0xFFABA4C4),
    inputFill: Color(0xFF252033),
    shadowBase: Colors.black,
    heroShellStart: Color(0xFF1A1625),
    heroShellMid: Color(0xFF221E30),
    heroShellEnd: Color(0xFF2A2438),
    brandIndigo: Color(0xFFA5B4FC),
    accent: Color(0xFFA78BFA),
    accentBorder: Color(0xFF8B5CF6),
    accentDeep: Color(0xFF6D28D9),
    gold: Color(0xFFFDE68A),
    insightFooter: Color(0xFFC4B5FD),
    tempAmber: Color(0xFFFBBF24),
    onAccent: Colors.white,
    progressTrack: Color(0xFF2A2438),
    heroTempGradientEnd: Color(0xFF818CF8),
  );

  @override
  WeatherlyPalette copyWith({
    Color? ink,
    Color? muted,
    Color? border,
  }) {
    return WeatherlyPalette(
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      surface0: surface0,
      surface1: surface1,
      surface2: surface2,
      cardStart: cardStart,
      cardEnd: cardEnd,
      topBarStart: topBarStart,
      topBarEnd: topBarEnd,
      citiesPageTop: citiesPageTop,
      citiesPageBottom: citiesPageBottom,
      cityCardTitle: cityCardTitle,
      cityCardSub: cityCardSub,
      inputFill: inputFill,
      shadowBase: shadowBase,
      heroShellStart: heroShellStart,
      heroShellMid: heroShellMid,
      heroShellEnd: heroShellEnd,
      brandIndigo: brandIndigo,
      accent: accent,
      accentBorder: accentBorder,
      accentDeep: accentDeep,
      gold: gold,
      insightFooter: insightFooter,
      tempAmber: tempAmber,
      onAccent: onAccent,
      progressTrack: progressTrack,
      heroTempGradientEnd: heroTempGradientEnd,
    );
  }

  @override
  WeatherlyPalette lerp(ThemeExtension<WeatherlyPalette>? other, double t) {
    if (other is! WeatherlyPalette) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}

extension WeatherlyPaletteContext on BuildContext {
  WeatherlyPalette get palette =>
      Theme.of(this).extension<WeatherlyPalette>() ?? WeatherlyPalette.light;
}
