import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../models/weather_models.dart';

String weatherEmoji(int code) {
  if (code == 0) return '☀️';
  if (code <= 3) return '⛅';
  if (code <= 67) return '🌧️';
  if (code <= 77) return '❄️';
  return '🌩️';
}

String weatherCategoryKey(int code) {
  if (code == 0) return 'weather.clear';
  if (code <= 3) return 'weather.cloudy';
  if (code <= 67) return 'weather.rain';
  if (code <= 77) return 'weather.snow';
  return 'weather.storm';
}

String weatherLabel(int code) =>
    AppStrings.weatherLabelForKey(weatherCategoryKey(code));

String cityWeatherSubtitle(WeatherResult data) {
  final time = DateFormat.jm().format(DateTime.parse(data.current.time));
  return '$time • ${weatherLabel(data.current.weatherCode)}';
}

String weatherConditionSubtitle(int code, {bool isNight = false}) {
  if (isNight && code == 0) {
    return '${AppStrings.weatherClear} Night';
  }
  if (isNight && code == 1) {
    return '${AppStrings.weatherClear} · ${AppStrings.weatherCloudy}';
  }
  final base = weatherLabel(code);
  if (code == 0) return '$base & Clear';
  if (code <= 3) return base;
  if (code <= 67) return 'Rain & Showers';
  if (code <= 77) return 'Snow & Cold';
  return 'Storms';
}

String weatherEmojiFor(int code, {bool isNight = false}) {
  if (isNight && code <= 1) return '🌙';
  return weatherEmoji(code);
}

String dailyConditionLabel(int code) {
  if (code == 0) return AppStrings.weatherClear;
  if (code <= 3) return AppStrings.weatherCloudy;
  if (code <= 67) return 'Showers';
  if (code <= 77) return AppStrings.weatherSnow;
  if (code == 1) return 'Sunny';
  return AppStrings.weatherStorm;
}

const _windCompass = [
  'N',
  'NNE',
  'NE',
  'ENE',
  'E',
  'ESE',
  'SE',
  'SSE',
  'S',
  'SSW',
  'SW',
  'WSW',
  'W',
  'WNW',
  'NW',
  'NNW',
];

String windCompass(double? degrees) {
  if (degrees == null || !degrees.isFinite) {
    return '';
  }
  final i = (degrees / 22.5).round() % 16;
  return '${_windCompass[i]} (${degrees.round()}°)';
}

String windDisplayMph(double kmh, double? degrees) {
  final mph = (kmh * 0.621371).round();
  if (degrees == null || !degrees.isFinite) return '$mph mph';
  final i = (degrees / 22.5).round() % 16;
  return '$mph mph ${_windCompass[i]}';
}
