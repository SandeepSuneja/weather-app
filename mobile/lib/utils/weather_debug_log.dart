import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/weather_models.dart';

/// Prints the full dashboard payload to the Flutter/Dart console (debug builds).
void logDashboardWeather(WeatherResult data) {
  final json = const JsonEncoder.withIndent('  ').convert(_weatherResultToMap(data));
  debugPrint('[Weatherly dashboard] WeatherResult:\n$json');
}

Map<String, dynamic> _weatherResultToMap(WeatherResult r) {
  final c = r.current;
  return {
    'locationName': r.locationName,
    'location': r.location.toJson(),
    'latitude': r.latitude,
    'longitude': r.longitude,
    'current': {
      'time': c.time,
      'temperature': c.temperature,
      'feelsLike': c.feelsLike,
      'humidity': c.humidity,
      'windSpeed': c.windSpeed,
      'windDirectionDegrees': c.windDirectionDegrees,
      'weatherCode': c.weatherCode,
      'pressureMsl': c.pressureMsl,
      'cloudCoverPercent': c.cloudCoverPercent,
      'dewPoint': c.dewPoint,
      'precipitationMm': c.precipitationMm,
      'uvIndex': c.uvIndex,
    },
    'pollution': {
      'usAqi': r.pollution.usAqi,
      'pm10': r.pollution.pm10,
      'pm2_5': r.pollution.pm2_5,
      'carbonMonoxide': r.pollution.carbonMonoxide,
      'nitrogenDioxide': r.pollution.nitrogenDioxide,
      'ozone': r.pollution.ozone,
    },
    'hourly': r.hourly
        .map(
          (h) => {
            'time': h.time,
            'temperature': h.temperature,
            'weatherCode': h.weatherCode,
            'precipitationProbability': h.precipitationProbability,
            'relativeHumidity': h.relativeHumidity,
          },
        )
        .toList(),
    'daily': r.daily
        .map(
          (d) => {
            'date': d.date,
            'minTemp': d.minTemp,
            'maxTemp': d.maxTemp,
            'weatherCode': d.weatherCode,
            'precipProbabilityMax': d.precipProbabilityMax,
            'uvIndexMax': d.uvIndexMax,
            'windSpeedMax': d.windSpeedMax,
            'sunrise': d.sunrise,
            'sunset': d.sunset,
          },
        )
        .toList(),
  };
}
