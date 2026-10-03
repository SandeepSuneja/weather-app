import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'weatherly_palette.dart';
extension WeatherlyContext on BuildContext {
  WeatherlyLayout get weatherly => WeatherlyLayout._(this);
}

class WeatherlyLayout {
  WeatherlyLayout._(this._context)
      : _width = MediaQuery.sizeOf(_context).width,
        _height = MediaQuery.sizeOf(_context).height;

  final BuildContext _context;
  final double _width;
  final double _height;

  WeatherlyPalette get _p => _context.palette;

  double _wFrac(double fraction, {required double min, required double max}) =>
      (_width * fraction).clamp(min, max);

  double _hFrac(double fraction, {required double min, required double max}) =>
      (_height * fraction).clamp(min, max);

  double get pagePaddingH => _wFrac(0.062, min: 16, max: 28);
  double get pagePaddingV => _hFrac(0.028, min: 16, max: 28);
  double get sectionGap => _hFrac(0.028, min: 16, max: 32);
  double get gapM => _wFrac(0.041, min: 12, max: 20);
  double get gapS => _wFrac(0.021, min: 6, max: 12);
  double get gapXs => _wFrac(0.01, min: 4, max: 8);
  double get scrollBottomInset => _hFrac(0.11, min: 72, max: 112);

  double get topBarHeight => _hFrac(0.08, min: 56, max: 72);
  double get logoSize => _wFrac(0.103, min: 36, max: 44);
  double get heroHeight => _hFrac(0.48, min: 280, max: 420);
  double get heroIconSize => _wFrac(0.188, min: 56, max: 80);
  double get heroPillMinHeight => _hFrac(0.07, min: 48, max: 60);
  double get hourlyStripHeight => _hFrac(0.155, min: 108, max: 140);
  double get hourlyCardWidth => _wFrac(0.246, min: 76, max: 104);
  double get radarHeight => _hFrac(0.22, min: 140, max: 220);
  double get dayNameWidth => _wFrac(0.246, min: 64, max: 96);
  double get radiusL => _wFrac(0.062, min: 16, max: 28);
  double get radiusM => _wFrac(0.051, min: 14, max: 22);
  double get radiusS => _wFrac(0.041, min: 12, max: 18);

  double font(double base) =>
      (base * (_width / 360)).clamp(base * 0.88, base * 1.15);

  double _letterEm(double em, double fontSize) => fontSize * em;

  TextStyle _inter({
    required double size,
    required FontWeight weight,
    required double lineHeight,
    double letterSpacingEm = 0,
    Color? color,
  }) {
    final fontSize = font(size);
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: weight,
      height: lineHeight / fontSize,
      letterSpacing: _letterEm(letterSpacingEm, fontSize),
      color: color ?? _p.ink,
    );
  }

  TextStyle get textAppTitle =>
      _inter(size: 20, weight: FontWeight.w700, lineHeight: 26, letterSpacingEm: -0.01);

  TextStyle heroTemperature({Color? color}) {
    final fontSize = _wFrac(0.308, min: 72, max: 120);
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: _letterEm(-0.05, fontSize),
      color: color ?? _p.ink,
    );
  }

  TextStyle get textHeroCondition =>
      _inter(size: 20, weight: FontWeight.w600, lineHeight: 26, letterSpacingEm: -0.01, color: _p.muted);

  TextStyle get textHeroLocationCity =>
      _inter(size: 17, weight: FontWeight.w700, lineHeight: 22, letterSpacingEm: -0.02);

  TextStyle get textHeroLocationCountry => sectionLabel(color: _p.accent);

  TextStyle get textHeroMetric => _inter(size: 13, weight: FontWeight.w400, lineHeight: 20.8);

  TextStyle sectionLabel({Color? color}) =>
      _inter(size: 12, weight: FontWeight.w600, lineHeight: 12, letterSpacingEm: 0.05, color: color ?? _p.muted);

  TextStyle get textAiCardTitle => sectionLabel(color: _p.gold);

  TextStyle get textAiQuote =>
      _inter(size: 18, weight: FontWeight.w700, lineHeight: 35, letterSpacingEm: 0.05, color: _p.onAccent);

  TextStyle aiFooter({Color? color}) =>
      _inter(size: 12, weight: FontWeight.w400, lineHeight: 16, color: color ?? _p.insightFooter);

  TextStyle get textStatValue =>
      _inter(size: 16, weight: FontWeight.w700, lineHeight: 26, letterSpacingEm: -0.01);

  TextStyle hourlyTemp({Color? color}) => textStatValue.copyWith(color: color ?? _p.ink);

  TextStyle get textDayName => _inter(size: 16, weight: FontWeight.w700, lineHeight: 25.6);

  TextStyle get textDayCondition =>
      _inter(size: 14, weight: FontWeight.w400, lineHeight: 21, color: _p.muted);

  TextStyle get textDayTempLow =>
      _inter(size: 20, weight: FontWeight.w600, lineHeight: 26, letterSpacingEm: -0.01);

  TextStyle navLabel({Color? color}) => sectionLabel(color: color ?? _p.muted);

  TextStyle get textCitiesBrand => _inter(
        size: 20,
        weight: FontWeight.w800,
        lineHeight: 26,
        letterSpacingEm: -0.025,
        color: _p.brandIndigo,
      );

  TextStyle get textCityName => _inter(
        size: 20,
        weight: FontWeight.w600,
        lineHeight: 26,
        letterSpacingEm: -0.01,
        color: _p.cityCardTitle,
      );

  TextStyle get textCityMeta =>
      _inter(size: 14, weight: FontWeight.w400, lineHeight: 21, color: _p.cityCardSub);

  TextStyle get textCityTemp => _inter(
        size: 32,
        weight: FontWeight.w600,
        lineHeight: 38.4,
        letterSpacingEm: -0.02,
        color: _p.tempAmber,
      );

  TextStyle citiesSectionLabel({Color? color}) =>
      _inter(size: 12, weight: FontWeight.w600, lineHeight: 12, letterSpacingEm: 0.1, color: color ?? _p.brandIndigo);

  TextStyle get textCitiesAction => _inter(
        size: 12,
        weight: FontWeight.w600,
        lineHeight: 12,
        letterSpacingEm: 0.05,
        color: _p.accent,
      );

  double get citiesMapHeight => _hFrac(0.24, min: 160, max: 220);

  TextStyle get textChipLabel => sectionLabel(color: _p.ink);

  double get statGridAspectRatio {
    final cellWidth = (_width - pagePaddingH * 2 - gapM) / 2;
    final cellHeight = _hFrac(0.125, min: 88, max: 108);
    return cellWidth / cellHeight;
  }
}
