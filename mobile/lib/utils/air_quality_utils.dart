import 'package:flutter/material.dart';

import '../models/weather_models.dart';

class AqiCategory {
  const AqiCategory({
    required this.label,
    required this.shortDescription,
    required this.color,
  });

  final String label;
  final String shortDescription;
  final Color color;
}

AqiCategory aqiCategoryFor(int aqi) {
  if (aqi <= 50) {
    return const AqiCategory(
      label: 'Good',
      shortDescription: 'Air is clean — great for outdoor plans.',
      color: Color(0xFF22C55E),
    );
  }
  if (aqi <= 100) {
    return const AqiCategory(
      label: 'Moderate',
      shortDescription: 'Acceptable; sensitive people may notice.',
      color: Color(0xFFEAB308),
    );
  }
  if (aqi <= 150) {
    return const AqiCategory(
      label: 'Sensitive',
      shortDescription: 'Unhealthy for sensitive groups.',
      color: Color(0xFFF97316),
    );
  }
  if (aqi <= 200) {
    return const AqiCategory(
      label: 'Unhealthy',
      shortDescription: 'Limit long outdoor exertion.',
      color: Color(0xFFEF4444),
    );
  }
  if (aqi <= 300) {
    return const AqiCategory(
      label: 'Very unhealthy',
      shortDescription: 'Avoid prolonged outdoor activity.',
      color: Color(0xFF9333EA),
    );
  }
  return const AqiCategory(
    label: 'Hazardous',
    shortDescription: 'Stay indoors when possible.',
    color: Color(0xFF7F1D1D),
  );
}

double aqiProgress(int aqi) => (aqi / 300).clamp(0.0, 1.0);

bool pollutionHasReadings(PollutionData data) {
  return data.usAqi != null ||
      data.pm2_5 != null ||
      data.pm10 != null ||
      data.nitrogenDioxide != null ||
      data.ozone != null ||
      data.carbonMonoxide != null;
}

String formatPollutantMicrograms(double? value) {
  if (value == null) return '—';
  if (value >= 100) return '${value.round()}';
  if (value >= 10) return value.toStringAsFixed(1);
  return value.toStringAsFixed(2);
}
