import 'package:intl/intl.dart';

import '../../models/weather_chart_models.dart';
import '../../models/weather_models.dart';

/// How many x-axis slots to skip between labels (~5–6 labels across the chart).
int chartBottomTickStep(int pointCount) {
  if (pointCount <= 1) return 1;
  if (pointCount <= 6) return 1;
  if (pointCount <= 12) return 2;
  if (pointCount <= 24) return 4;
  if (pointCount <= 48) return 6;
  return (pointCount / 5).ceil().clamp(2, 12);
}

bool chartShowBottomTick(int index, int pointCount) {
  if (index < 0 || index >= pointCount) return false;
  if (index == 0) return true;
  if (index == pointCount - 1) return true;
  final step = chartBottomTickStep(pointCount);
  return index % step == 0;
}

String chartHourlyTimeLabel(
  List<HourlyChartPoint> points,
  int index, {
  DateFormat? formatter,
}) {
  if (index == 0) return 'Now';
  final fmt = formatter ?? DateFormat('ha');
  return fmt.format(points[index].time.toLocal());
}

String chartDailyDateLabel(List<DayForecast> days, int index, DateFormat dayFmt) {
  if (index == 0) return 'Today';
  return dayFmt.format(DateTime.parse(days[index].date));
}

String chartAirQualityTimeLabel(
  List<HourlyAirQualityPoint> points,
  int index, {
  DateFormat? formatter,
}) {
  if (index == 0) return 'Now';
  final fmt = formatter ?? DateFormat('ha');
  return fmt.format(points[index].time.toLocal());
}
