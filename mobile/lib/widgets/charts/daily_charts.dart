import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_strings.dart';
import '../../models/weather_models.dart';
import '../../theme/weatherly_responsive.dart';
import 'chart_axis_utils.dart';
import 'chart_interaction.dart';
import 'metric_chart_card.dart';
import 'weather_fl_chart_theme.dart';

List<Widget> buildDailyChartSections({
  required BuildContext context,
  required WeatherResult weather,
  required double sectionGap,
}) {
  return [
    _DailyTemperatureChart(weather: weather),
    SizedBox(height: sectionGap),
    _DailyPrecipChart(weather: weather),
    SizedBox(height: sectionGap),
    _DailyWindChart(weather: weather),
  ];
}

class _DailyTemperatureChart extends StatelessWidget {
  const _DailyTemperatureChart({required this.weather});

  final WeatherResult weather;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final days = weather.daily.take(7).toList();
    if (days.isEmpty) return const SizedBox.shrink();
    final dayFmt = DateFormat.E();
    final tickStep = chartBottomTickStep(days.length);

    final minTemps = days.map((d) => d.minTemp).toList();
    final maxTemps = days.map((d) => d.maxTemp).toList();
    final minY = minTemps.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = maxTemps.reduce((a, b) => a > b ? a : b) + 2;

    return MetricChartCard(
      title: AppStrings.chartDailyTemperature,
      subtitle: AppStrings.chartDailyTemperatureSubtitle,
      showTouchHint: true,
      height: context.weatherly.font(220),
      chart: BarChart(
        BarChartData(
          minY: minY,
          maxY: maxY,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          barTouchData: weatherBarTouch(
            palette: theme.p,
            headerAtIndex: (i) => chartDailyDateLabel(days, i, dayFmt),
            valueAtIndex: (i) =>
                '${days[i].minTemp.round()}° – ${days[i].maxTemp.round()}°',
          ),
          titlesData: theme.axisTitles(
            bottomCount: days.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartDailyDateLabel(days, i, dayFmt),
            leftInterval: ((maxY - minY) / 4).clamp(1, 999).toDouble(),
            leftFormat: (v) => '${v.round()}°',
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    fromY: days[i].minTemp,
                    toY: days[i].maxTemp,
                    width: 14,
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [theme.p.accentDeep, theme.p.tempAmber],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DailyPrecipChart extends StatelessWidget {
  const _DailyPrecipChart({required this.weather});

  final WeatherResult weather;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final days = weather.daily.take(7).toList();
    if (days.isEmpty) return const SizedBox.shrink();
    final dayFmt = DateFormat.E();
    final tickStep = chartBottomTickStep(days.length);

    return MetricChartCard(
      title: AppStrings.chartDailyPrecip,
      subtitle: AppStrings.dailyPrecip,
      chart: BarChart(
        BarChartData(
          maxY: 100,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          barTouchData: weatherBarTouch(
            palette: theme.p,
            headerAtIndex: (i) => chartDailyDateLabel(days, i, dayFmt),
            valueAtIndex: (i) => '${days[i].precipProbabilityMax ?? 0}%',
          ),
          titlesData: theme.axisTitles(
            bottomCount: days.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartDailyDateLabel(days, i, dayFmt),
            leftInterval: 25,
            leftFormat: (v) => '${v.round()}%',
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: (days[i].precipProbabilityMax ?? 0).toDouble(),
                    width: 14,
                    borderRadius: BorderRadius.circular(6),
                    color: theme.p.accent,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DailyWindChart extends StatelessWidget {
  const _DailyWindChart({required this.weather});

  final WeatherResult weather;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final days = weather.daily.take(7).toList();
    if (days.isEmpty) return const SizedBox.shrink();
    final dayFmt = DateFormat.E();
    final tickStep = chartBottomTickStep(days.length);
    final maxY = days.map((d) => d.windSpeedMax ?? 0).reduce((a, b) => a > b ? a : b) + 4;

    return MetricChartCard(
      title: AppStrings.chartDailyWind,
      subtitle: AppStrings.dailyWind,
      chart: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          barTouchData: weatherBarTouch(
            palette: theme.p,
            headerAtIndex: (i) => chartDailyDateLabel(days, i, dayFmt),
            valueAtIndex: (i) => '${(days[i].windSpeedMax ?? 0).round()} km/h',
          ),
          titlesData: theme.axisTitles(
            bottomCount: days.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartDailyDateLabel(days, i, dayFmt),
            leftInterval: (maxY / 4).clamp(1, 999).toDouble(),
            leftFormat: (v) => '${v.round()}',
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: days[i].windSpeedMax ?? 0,
                    width: 14,
                    borderRadius: BorderRadius.circular(6),
                    color: theme.p.brandIndigo,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
