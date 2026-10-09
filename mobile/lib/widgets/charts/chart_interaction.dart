import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/weatherly_palette.dart';

LineTouchData weatherLineTouch({
  required WeatherlyPalette palette,
  required String Function(int index) headerAtIndex,
  required List<String Function(int index)> valueLinesAtIndex,
}) {
  return LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
      tooltipRoundedRadius: 10,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      getTooltipColor: (_) => palette.cardStart,
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      getTooltipItems: (touchedSpots) {
        if (touchedSpots.isEmpty) return [];
        final index = touchedSpots.first.x.round();
        final header = headerAtIndex(index);
        final lines = valueLinesAtIndex
            .map((line) => line(index))
            .where((text) => text.isNotEmpty)
            .join('\n');
        return [
          LineTooltipItem(
            lines.isEmpty ? header : '$header\n$lines',
            GoogleFonts.inter(
              color: palette.ink,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ];
      },
    ),
  );
}

BarTouchData weatherBarTouch({
  required WeatherlyPalette palette,
  required String Function(int index) headerAtIndex,
  required String Function(int index) valueAtIndex,
}) {
  return BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      tooltipRoundedRadius: 10,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      getTooltipColor: (_) => palette.cardStart,
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final header = headerAtIndex(groupIndex);
        final value = valueAtIndex(groupIndex);
        return BarTooltipItem(
          '$header\n$value',
          GoogleFonts.inter(
            color: palette.ink,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            height: 1.35,
          ),
        );
      },
    ),
  );
}
