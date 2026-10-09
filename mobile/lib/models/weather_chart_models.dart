/// Hourly points for charting (from current hour forward).
class HourlyChartPoint {
  const HourlyChartPoint({
    required this.time,
    required this.temperature,
    this.apparentTemperature,
    this.precipitationProbability,
    this.relativeHumidity,
    this.windSpeed,
    this.precipitationMm,
    this.pressureMsl,
    this.cloudCover,
    this.uvIndex,
    this.dewPoint,
  });

  final DateTime time;
  final double temperature;
  final double? apparentTemperature;
  final int? precipitationProbability;
  final int? relativeHumidity;
  final double? windSpeed;
  final double? precipitationMm;
  final double? pressureMsl;
  final int? cloudCover;
  final double? uvIndex;
  final double? dewPoint;
}

class HourlyAirQualityPoint {
  const HourlyAirQualityPoint({
    required this.time,
    this.usAqi,
    this.pm2_5,
    this.pm10,
  });

  final DateTime time;
  final int? usAqi;
  final double? pm2_5;
  final double? pm10;
}

/// Chart-ready series bundled with each weather fetch (no extra API round-trip).
class WeatherChartData {
  const WeatherChartData({
    required this.hourly,
    required this.airQualityHourly,
  });

  final List<HourlyChartPoint> hourly;
  final List<HourlyAirQualityPoint> airQualityHourly;

  List<HourlyChartPoint> hourlyForHours(int hours) {
    if (hourly.isEmpty) return hourly;
    final end = hourly.first.time.add(Duration(hours: hours));
    return hourly.where((p) => !p.time.isAfter(end)).toList();
  }

  List<HourlyAirQualityPoint> airQualityForHours(int hours) {
    if (airQualityHourly.isEmpty) return airQualityHourly;
    final end = airQualityHourly.first.time.add(Duration(hours: hours));
    return airQualityHourly.where((p) => !p.time.isAfter(end)).toList();
  }
}

enum ChartTimeRange {
  hours24,
  hours48,
  days7,
}

extension ChartTimeRangeLabel on ChartTimeRange {
  String get label => switch (this) {
        ChartTimeRange.hours24 => '24h',
        ChartTimeRange.hours48 => '48h',
        ChartTimeRange.days7 => '7d',
      };

  int? get hourlyHours => switch (this) {
        ChartTimeRange.hours24 => 24,
        ChartTimeRange.hours48 => 48,
        ChartTimeRange.days7 => null,
      };

  bool get isHourly => hourlyHours != null;
}
