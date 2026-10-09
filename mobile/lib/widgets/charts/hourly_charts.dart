import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_strings.dart';
import '../../models/weather_chart_models.dart';
import '../../models/weather_models.dart';
import '../../utils/air_quality_utils.dart';
import 'chart_axis_utils.dart';
import 'chart_interaction.dart';
import 'chart_legend.dart';
import 'metric_chart_card.dart';
import 'weather_fl_chart_theme.dart';

List<Widget> buildHourlyChartSections({
  required BuildContext context,
  required WeatherResult weather,
  required int hourWindow,
  required double sectionGap,
}) {
  return [
    _TemperatureHourlyChart(weather: weather, hourWindow: hourWindow),
    SizedBox(height: sectionGap),
    _PrecipitationHourlyChart(weather: weather, hourWindow: hourWindow),
    SizedBox(height: sectionGap),
    _WindHourlyChart(weather: weather, hourWindow: hourWindow),
    SizedBox(height: sectionGap),
    _HumidityHourlyChart(weather: weather, hourWindow: hourWindow),
    SizedBox(height: sectionGap),
    _PressureHourlyChart(weather: weather, hourWindow: hourWindow),
    SizedBox(height: sectionGap),
    _UvHourlyChart(weather: weather, hourWindow: hourWindow),
    SizedBox(height: sectionGap),
    _CloudCoverHourlyChart(weather: weather, hourWindow: hourWindow),
    if (weather.charts.airQualityHourly.any((p) => p.usAqi != null)) ...[
      SizedBox(height: sectionGap),
      _AqiHourlyChart(weather: weather, hourWindow: hourWindow),
    ],
    if (_hasParticulateSeries(weather, hourWindow)) ...[
      SizedBox(height: sectionGap),
      _ParticulateHourlyChart(weather: weather, hourWindow: hourWindow),
    ],
  ];
}

bool _hasParticulateSeries(WeatherResult weather, int hourWindow) {
  final pts = weather.charts.airQualityForHours(hourWindow);
  return pts.any((p) => p.pm2_5 != null || p.pm10 != null);
}

String _hourHeader(List<HourlyChartPoint> points, int index, DateFormat timeFmt) {
  if (index < 0 || index >= points.length) return '';
  if (index == 0) return 'Now';
  return timeFmt.format(points[index].time.toLocal());
}

String _aqHeader(List<HourlyAirQualityPoint> points, int index, DateFormat timeFmt) {
  if (index < 0 || index >= points.length) return '';
  if (index == 0) return 'Now';
  return timeFmt.format(points[index].time.toLocal());
}

class _TemperatureHourlyChart extends StatelessWidget {
  const _TemperatureHourlyChart({required this.weather, required this.hourWindow});

  final WeatherResult weather;
  final int hourWindow;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final points = weather.charts.hourlyForHours(hourWindow);
    if (points.isEmpty) return const SizedBox.shrink();

    final temps = points.map((p) => p.temperature).toList();
    final minY = temps.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = temps.reduce((a, b) => a > b ? a : b) + 2;
    final timeFmt = DateFormat('h a');
    final tickStep = chartBottomTickStep(points.length);

    final tempSpots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].temperature),
    ];
    final feelSpots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      final f = points[i].apparentTemperature;
      if (f != null) feelSpots.add(FlSpot(i.toDouble(), f));
    }

    return MetricChartCard(
      title: AppStrings.chartTemperature,
      subtitle: AppStrings.chartTemperatureSubtitle,
      showTouchHint: true,
      legend: ChartLegendRow(
        entries: [
          ChartLegendEntry(label: AppStrings.chartLegendActual, color: theme.p.accent),
          if (feelSpots.isNotEmpty)
            ChartLegendEntry(
              label: AppStrings.chartLegendFeelsLike,
              color: theme.p.tempAmber,
              dashed: true,
            ),
        ],
      ),
      chart: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          lineTouchData: weatherLineTouch(
            palette: theme.p,
            headerAtIndex: (i) => _hourHeader(points, i, timeFmt),
            valueLinesAtIndex: [
              (i) => '${AppStrings.chartLegendActual}: ${points[i].temperature.round()}°',
              (i) {
                final f = points[i].apparentTemperature;
                if (f == null) return '';
                return '${AppStrings.chartLegendFeelsLike}: ${f.round()}°';
              },
            ],
          ),
          titlesData: theme.axisTitles(
            bottomCount: points.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartHourlyTimeLabel(points, i, formatter: timeFmt),
            leftInterval: ((maxY - minY) / 4).clamp(1, 999).toDouble(),
            leftFormat: (v) => '${v.round()}°',
          ),
          lineBarsData: [
            theme.line(spots: tempSpots, color: theme.p.accent),
            if (feelSpots.isNotEmpty)
              theme.line(spots: feelSpots, color: theme.p.tempAmber, dashed: true),
          ],
        ),
      ),
    );
  }
}

class _PrecipitationHourlyChart extends StatelessWidget {
  const _PrecipitationHourlyChart({required this.weather, required this.hourWindow});

  final WeatherResult weather;
  final int hourWindow;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final points = weather.charts.hourlyForHours(hourWindow);
    if (points.isEmpty) return const SizedBox.shrink();
    final timeFmt = DateFormat('h a');
    final tickStep = chartBottomTickStep(points.length);

    return MetricChartCard(
      title: AppStrings.chartPrecipitation,
      subtitle: AppStrings.chartPrecipitationSubtitle,
      chart: BarChart(
        BarChartData(
          maxY: 100,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          barTouchData: weatherBarTouch(
            palette: theme.p,
            headerAtIndex: (i) => _hourHeader(points, i, timeFmt),
            valueAtIndex: (i) => '${points[i].precipitationProbability ?? 0}%',
          ),
          titlesData: theme.axisTitles(
            bottomCount: points.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartHourlyTimeLabel(points, i, formatter: timeFmt),
            leftInterval: 25,
            leftFormat: (v) => '${v.round()}%',
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: (points[i].precipitationProbability ?? 0).toDouble(),
                    width: points.length > 30 ? 8 : 10,
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [theme.p.accentDeep, theme.p.accent],
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

class _WindHourlyChart extends StatelessWidget {
  const _WindHourlyChart({required this.weather, required this.hourWindow});

  final WeatherResult weather;
  final int hourWindow;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final points = weather.charts.hourlyForHours(hourWindow);
    if (points.isEmpty) return const SizedBox.shrink();

    final speeds = points.map((p) => p.windSpeed ?? 0).toList();
    final maxY = speeds.reduce((a, b) => a > b ? a : b) + 4;
    final timeFmt = DateFormat('h a');
    final tickStep = chartBottomTickStep(points.length);
    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].windSpeed ?? 0),
    ];

    return MetricChartCard(
      title: AppStrings.chartWind,
      subtitle: AppStrings.chartWindSubtitle,
      chart: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          lineTouchData: weatherLineTouch(
            palette: theme.p,
            headerAtIndex: (i) => _hourHeader(points, i, timeFmt),
            valueLinesAtIndex: [
              (i) => '${(points[i].windSpeed ?? 0).round()} km/h',
            ],
          ),
          titlesData: theme.axisTitles(
            bottomCount: points.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartHourlyTimeLabel(points, i, formatter: timeFmt),
            leftInterval: (maxY / 4).clamp(1, 999).toDouble(),
            leftFormat: (v) => '${v.round()}',
          ),
          lineBarsData: [
            theme.line(spots: spots, color: theme.p.brandIndigo),
          ],
        ),
      ),
    );
  }
}

class _HumidityHourlyChart extends StatelessWidget {
  const _HumidityHourlyChart({required this.weather, required this.hourWindow});

  final WeatherResult weather;
  final int hourWindow;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final points = weather.charts.hourlyForHours(hourWindow);
    if (points.isEmpty) return const SizedBox.shrink();
    final timeFmt = DateFormat('h a');
    final tickStep = chartBottomTickStep(points.length);
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), (points[i].relativeHumidity ?? 0).toDouble()),
    ];

    return MetricChartCard(
      title: AppStrings.chartHumidity,
      subtitle: AppStrings.chartHumiditySubtitle,
      chart: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          lineTouchData: weatherLineTouch(
            palette: theme.p,
            headerAtIndex: (i) => _hourHeader(points, i, timeFmt),
            valueLinesAtIndex: [
              (i) => '${points[i].relativeHumidity ?? 0}%',
            ],
          ),
          titlesData: theme.axisTitles(
            bottomCount: points.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartHourlyTimeLabel(points, i, formatter: timeFmt),
            leftInterval: 25,
            leftFormat: (v) => '${v.round()}%',
          ),
          lineBarsData: [
            theme.line(spots: spots, color: theme.p.accentBorder),
          ],
        ),
      ),
    );
  }
}

class _PressureHourlyChart extends StatelessWidget {
  const _PressureHourlyChart({required this.weather, required this.hourWindow});

  final WeatherResult weather;
  final int hourWindow;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final points = weather.charts.hourlyForHours(hourWindow)
        .where((p) => p.pressureMsl != null)
        .toList();
    if (points.length < 2) return const SizedBox.shrink();

    final values = points.map((p) => p.pressureMsl!).toList();
    final minY = values.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = values.reduce((a, b) => a > b ? a : b) + 2;
    final timeFmt = DateFormat('h a');
    final tickStep = chartBottomTickStep(points.length);
    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].pressureMsl!),
    ];

    return MetricChartCard(
      title: AppStrings.chartPressure,
      subtitle: AppStrings.chartPressureSubtitle,
      chart: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          lineTouchData: weatherLineTouch(
            palette: theme.p,
            headerAtIndex: (i) => _hourHeader(points, i, timeFmt),
            valueLinesAtIndex: [
              (i) => '${points[i].pressureMsl!.round()} hPa',
            ],
          ),
          titlesData: theme.axisTitles(
            bottomCount: points.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartHourlyTimeLabel(points, i, formatter: timeFmt),
            leftInterval: ((maxY - minY) / 4).clamp(1, 999).toDouble(),
            leftFormat: (v) => '${v.round()}',
          ),
          lineBarsData: [
            theme.line(spots: spots, color: theme.p.muted),
          ],
        ),
      ),
    );
  }
}

class _UvHourlyChart extends StatelessWidget {
  const _UvHourlyChart({required this.weather, required this.hourWindow});

  final WeatherResult weather;
  final int hourWindow;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final points = weather.charts.hourlyForHours(hourWindow)
        .where((p) => p.uvIndex != null)
        .toList();
    if (points.isEmpty) return const SizedBox.shrink();

    final maxY = points.map((p) => p.uvIndex!).reduce((a, b) => a > b ? a : b) + 1;
    final timeFmt = DateFormat('h a');
    final tickStep = chartBottomTickStep(points.length);
    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].uvIndex!),
    ];

    return MetricChartCard(
      title: AppStrings.chartUv,
      subtitle: AppStrings.chartUvSubtitle,
      chart: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: maxY.clamp(3, 14),
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          lineTouchData: weatherLineTouch(
            palette: theme.p,
            headerAtIndex: (i) => _hourHeader(points, i, timeFmt),
            valueLinesAtIndex: [
              (i) => points[i].uvIndex!.toStringAsFixed(1),
            ],
          ),
          titlesData: theme.axisTitles(
            bottomCount: points.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartHourlyTimeLabel(points, i, formatter: timeFmt),
            leftInterval: 2,
            leftFormat: (v) => v.toStringAsFixed(0),
          ),
          lineBarsData: [
            theme.line(spots: spots, color: theme.p.tempAmber),
          ],
        ),
      ),
    );
  }
}

class _CloudCoverHourlyChart extends StatelessWidget {
  const _CloudCoverHourlyChart({required this.weather, required this.hourWindow});

  final WeatherResult weather;
  final int hourWindow;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final points = weather.charts.hourlyForHours(hourWindow)
        .where((p) => p.cloudCover != null)
        .toList();
    if (points.isEmpty) return const SizedBox.shrink();

    final timeFmt = DateFormat('h a');
    final tickStep = chartBottomTickStep(points.length);
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].cloudCover!.toDouble()),
    ];

    return MetricChartCard(
      title: AppStrings.chartCloudCover,
      subtitle: AppStrings.chartCloudCoverSubtitle,
      chart: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          lineTouchData: weatherLineTouch(
            palette: theme.p,
            headerAtIndex: (i) => _hourHeader(points, i, timeFmt),
            valueLinesAtIndex: [
              (i) => '${points[i].cloudCover}%',
            ],
          ),
          titlesData: theme.axisTitles(
            bottomCount: points.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartHourlyTimeLabel(points, i, formatter: timeFmt),
            leftInterval: 25,
            leftFormat: (v) => '${v.round()}%',
          ),
          lineBarsData: [
            theme.line(spots: spots, color: theme.p.brandIndigo.withValues(alpha: 0.85)),
          ],
        ),
      ),
    );
  }
}

class _AqiHourlyChart extends StatelessWidget {
  const _AqiHourlyChart({required this.weather, required this.hourWindow});

  final WeatherResult weather;
  final int hourWindow;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final points = weather.charts.airQualityForHours(hourWindow)
        .where((p) => p.usAqi != null)
        .toList();
    if (points.isEmpty) return const SizedBox.shrink();

    final values = points.map((p) => p.usAqi!.toDouble()).toList();
    final maxY = values.reduce((a, b) => a > b ? a : b) + 20;
    final timeFmt = DateFormat('h a');
    final tickStep = chartBottomTickStep(points.length);
    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].usAqi!.toDouble()),
    ];

    return MetricChartCard(
      title: AppStrings.chartAirQuality,
      subtitle: AppStrings.chartAirQualitySubtitle,
      chart: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: maxY.clamp(50, 300).toDouble(),
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          lineTouchData: weatherLineTouch(
            palette: theme.p,
            headerAtIndex: (i) => _aqHeader(points, i, timeFmt),
            valueLinesAtIndex: [
              (i) => 'AQI ${points[i].usAqi}',
            ],
          ),
          titlesData: theme.axisTitles(
            bottomCount: points.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartAirQualityTimeLabel(points, i, formatter: timeFmt),
            leftInterval: 50,
            leftFormat: (v) => v.round().toString(),
          ),
          lineBarsData: [
            theme.line(spots: spots, color: const Color(0xFF22C55E)),
          ],
        ),
      ),
    );
  }
}

class _ParticulateHourlyChart extends StatelessWidget {
  const _ParticulateHourlyChart({required this.weather, required this.hourWindow});

  final WeatherResult weather;
  final int hourWindow;

  @override
  Widget build(BuildContext context) {
    final theme = WeatherFlChartTheme.of(context);
    final points = weather.charts.airQualityForHours(hourWindow);
    if (points.isEmpty) return const SizedBox.shrink();

    final pm25Spots = <FlSpot>[];
    final pm10Spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      if (p.pm2_5 != null) pm25Spots.add(FlSpot(i.toDouble(), p.pm2_5!));
      if (p.pm10 != null) pm10Spots.add(FlSpot(i.toDouble(), p.pm10!));
    }
    if (pm25Spots.isEmpty && pm10Spots.isEmpty) return const SizedBox.shrink();

    final allY = [
      ...pm25Spots.map((s) => s.y),
      ...pm10Spots.map((s) => s.y),
    ];
    final maxY = allY.reduce((a, b) => a > b ? a : b) * 1.15 + 1;
    final timeFmt = DateFormat('h a');
    final tickStep = chartBottomTickStep(points.length);

    return MetricChartCard(
      title: AppStrings.chartParticulates,
      subtitle: AppStrings.chartParticulatesSubtitle,
      legend: ChartLegendRow(
        entries: [
          if (pm25Spots.isNotEmpty)
            ChartLegendEntry(label: AppStrings.chartLegendPm25, color: theme.p.accent),
          if (pm10Spots.isNotEmpty)
            ChartLegendEntry(
              label: AppStrings.chartLegendPm10,
              color: theme.p.brandIndigo,
              dashed: true,
            ),
        ],
      ),
      chart: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: theme.grid(),
          borderData: FlBorderData(show: false),
          lineTouchData: weatherLineTouch(
            palette: theme.p,
            headerAtIndex: (i) => _aqHeader(points, i, timeFmt),
            valueLinesAtIndex: [
              (i) {
                final v = points[i].pm2_5;
                if (v == null) return '';
                return '${AppStrings.chartLegendPm25}: ${formatPollutantMicrograms(v)}';
              },
              (i) {
                final v = points[i].pm10;
                if (v == null) return '';
                return '${AppStrings.chartLegendPm10}: ${formatPollutantMicrograms(v)}';
              },
            ],
          ),
          titlesData: theme.axisTitles(
            bottomCount: points.length,
            bottomTickStep: tickStep,
            bottomLabel: (i) => chartAirQualityTimeLabel(points, i, formatter: timeFmt),
            leftInterval: (maxY / 4).clamp(1, 999).toDouble(),
            leftFormat: (v) => v.round().toString(),
          ),
          lineBarsData: [
            if (pm25Spots.isNotEmpty)
              theme.line(spots: pm25Spots, color: theme.p.accent),
            if (pm10Spots.isNotEmpty)
              theme.line(spots: pm10Spots, color: theme.p.brandIndigo, dashed: true),
          ],
        ),
      ),
    );
  }
}
