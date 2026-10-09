import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/weatherly_palette.dart';
import '../../theme/weatherly_responsive.dart';

class WeatherFlChartTheme {
  WeatherFlChartTheme._(this.context)
      : p = context.palette,
        lay = context.weatherly;

  final BuildContext context;
  final WeatherlyPalette p;
  final WeatherlyLayout lay;

  factory WeatherFlChartTheme.of(BuildContext context) => WeatherFlChartTheme._(context);

  FlGridData grid({int horizontalCount = 4}) => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (_) => FlLine(
          color: p.border.withValues(alpha: 0.45),
          strokeWidth: 1,
        ),
      );

  FlTitlesData bottomTitles({
    required int count,
    required String Function(int index) labelForIndex,
    int? tickStep,
  }) {
    final step = tickStep ?? (count <= 1 ? 1 : (count / 5).ceil().clamp(1, 12));
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: lay.font(36),
          interval: step.toDouble(),
          getTitlesWidget: (value, meta) {
            final i = value.round();
            if (i < 0 || i >= count) return const SizedBox.shrink();
            final show = i == 0 || i == count - 1 || i % step == 0;
            if (!show) return const SizedBox.shrink();
            final text = labelForIndex(i);
            return Padding(
              padding: EdgeInsets.only(top: lay.gapXs),
              child: Transform.rotate(
                angle: count > 10 ? -0.45 : 0,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: lay.sectionLabel().copyWith(fontSize: lay.font(9)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  FlTitlesData leftTitles({
    required double interval,
    required String Function(double value) format,
  }) {
    return FlTitlesData(
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: lay.font(36),
          interval: interval,
          getTitlesWidget: (value, meta) => Text(
            format(value),
            style: lay.sectionLabel().copyWith(fontSize: lay.font(9)),
          ),
        ),
      ),
    );
  }

  FlTitlesData axisTitles({
    required int bottomCount,
    required String Function(int index) bottomLabel,
    required double leftInterval,
    required String Function(double value) leftFormat,
    int? bottomTickStep,
  }) {
    final bottom = bottomTitles(
      count: bottomCount,
      labelForIndex: bottomLabel,
      tickStep: bottomTickStep,
    );
    final left = leftTitles(interval: leftInterval, format: leftFormat);
    return FlTitlesData(
      leftTitles: left.leftTitles,
      bottomTitles: bottom.bottomTitles,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineChartBarData line({
    required List<FlSpot> spots,
    required Color color,
    bool dashed = false,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.22,
      color: color,
      barWidth: 2.8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: spots.length <= 16,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 1,
          strokeColor: p.surface0,
        ),
      ),
      belowBarData: BarAreaData(
        show: !dashed,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.02),
          ],
        ),
      ),
      dashArray: dashed ? [6, 4] : null,
    );
  }
}
