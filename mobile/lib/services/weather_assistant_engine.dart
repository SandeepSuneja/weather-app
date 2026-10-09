import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../models/weather_models.dart';
import '../utils/weather_insight.dart';
import '../utils/weather_utils.dart';
import 'weather_topic_gate.dart';

/// Rule-based weather answers grounded in [WeatherResult] (Phase 0 — no LLM).
class WeatherAssistantEngine {
  String reply({required String userMessage, required WeatherResult? weather}) {
    if (weather == null) {
      return AppStrings.assistantNeedWeather;
    }

    final q = userMessage.trim();
    if (q.isEmpty) {
      return AppStrings.assistantEmptyPrompt;
    }

    if (!WeatherTopicGate.isWeatherRelated(q)) {
      return AppStrings.assistantOffTopic;
    }

    final lower = q.toLowerCase();

    if (_matchesAny(lower, ['umbrella', 'rain', 'wet', 'drizzle', 'shower', 'precipitation'])) {
      return _answerUmbrella(weather);
    }
    if (_matchesAny(lower, ['run', 'jog', 'walk', 'hike', 'exercise', 'bike', 'cycling', 'workout'])) {
      return _answerOutdoorActivity(weather);
    }
    if (_matchesAny(lower, ['wear', 'layer', 'jacket', 'coat', 'clothes', 'dress', 'shorts', 'outfit'])) {
      return _answerWhatToWear(weather);
    }
    if (_matchesAny(lower, ['aqi', 'air quality', 'pollution', 'pm2', 'pm10', 'breathe', 'smog'])) {
      return _answerAirQuality(weather);
    }
    if (_matchesAny(lower, ['weekend', 'this week', 'next week', '7 day', 'seven day', 'outlook'])) {
      return _answerWeekOutlook(weather);
    }
    if (_matchesAny(lower, ['tomorrow'])) {
      return _answerTomorrow(weather);
    }
    if (_matchesAny(lower, ['wind', 'breeze', 'gust'])) {
      return _answerWind(weather);
    }
    if (_matchesAny(lower, ['uv', 'sunburn', 'sunscreen', 'sunny', 'sun '])) {
      return _answerUv(weather);
    }
    if (_matchesAny(lower, ['summary', 'overview', 'tell me', 'how is', "how's", 'conditions'])) {
      return _answerSummary(weather);
    }
    if (_matchesAny(lower, ['cold', 'hot', 'warm', 'cool', 'temp', 'temperature', 'feels'])) {
      return _answerTemperature(weather);
    }

    return _answerSummary(weather);
  }

  List<String> get suggestedPrompts => const [
        AppStrings.assistantChipUmbrella,
        AppStrings.assistantChipRun,
        AppStrings.assistantChipWear,
        AppStrings.assistantChipAir,
        AppStrings.assistantChipWeekend,
        AppStrings.assistantChipSummary,
      ];

  bool _matchesAny(String lower, List<String> needles) {
    for (final n in needles) {
      if (lower.contains(n)) return true;
    }
    return false;
  }

  String _footer(WeatherResult weather) {
    final dt = DateTime.tryParse(weather.current.time);
    if (dt == null) {
      return '\n\n${AppStrings.assistantFooterLocation(weather.location.name)}';
    }
    final fmt = DateFormat('MMM d, h:mm a');
    return '\n\n${AppStrings.assistantFooterUpdated(weather.location.name, fmt.format(dt.toLocal()))}';
  }

  String _answerSummary(WeatherResult weather) {
    return '${buildWeatherInsight(weather)}${_footer(weather)}';
  }

  String _answerUmbrella(WeatherResult weather) {
    final c = weather.current;
    final hourly = weather.hourly;
    final nowRain = (c.precipitationMm ?? 0) > 0.2;
    final code = c.weatherCode;

    HourForecast? peak;
    for (final h in hourly) {
      final p = h.precipitationProbability ?? 0;
      if (peak == null || p > (peak.precipitationProbability ?? 0)) {
        peak = h;
      }
    }
    final peakProb = peak?.precipitationProbability ?? 0;

    if (nowRain ||
        (code >= 51 && code <= 67) ||
        (code >= 80 && code <= 82)) {
      return '${AppStrings.assistantUmbrellaYesNow} '
          '(${weatherLabel(c.weatherCode)}, ${c.temperature.round()}°).${_footer(weather)}';
    }
    if (peakProb >= 40) {
      final t = peak != null ? DateTime.tryParse(peak.time) : null;
      final when = t != null ? DateFormat('h a').format(t.toLocal()) : 'later';
      return '${AppStrings.assistantUmbrellaLater(peakProb, when)}${_footer(weather)}';
    }
    if (peakProb >= 20) {
      return '${AppStrings.assistantUmbrellaMaybe(peakProb)}${_footer(weather)}';
    }
    return '${AppStrings.assistantUmbrellaNo}${_footer(weather)}';
  }

  String _answerOutdoorActivity(WeatherResult weather) {
    final c = weather.current;
    final aqi = weather.pollution.usAqi;
    final temp = c.temperature;
    final rainSoon = weather.hourly.any((h) => (h.precipitationProbability ?? 0) >= 50);
    final wind = c.windSpeed;

    final issues = <String>[];
    if (rainSoon) issues.add('rain is likely in the next 12 hours');
    if (wind >= 30) issues.add('winds are strong (${wind.round()} km/h)');
    if (temp >= 35) issues.add('heat stress is possible (${temp.round()}°)');
    if (temp <= 2) issues.add('it is very cold (${temp.round()}°)');
    if (aqi != null && aqi > 100) issues.add('air quality is elevated (AQI $aqi)');

    if (issues.isEmpty) {
      return '${AppStrings.assistantRunGood(c.temperature.round(), c.humidity)}${_footer(weather)}';
    }
    return '${AppStrings.assistantRunCaution(issues.join('; '))}${_footer(weather)}';
  }

  String _answerWhatToWear(WeatherResult weather) {
    final c = weather.current;
    final feels = c.feelsLike;
    final rain = weather.hourly.any((h) => (h.precipitationProbability ?? 0) >= 35);
    final wind = c.windSpeed >= 20;

    final layers = <String>[];
    if (feels <= 5) {
      layers.add('a warm coat, hat, and gloves');
    } else if (feels <= 12) {
      layers.add('a jacket or fleece');
    } else if (feels <= 18) {
      layers.add('a light layer or long sleeves');
    } else if (feels <= 26) {
      layers.add('light, breathable clothing');
    } else {
      layers.add('very light clothing and stay hydrated');
    }
    if (rain) layers.add('a waterproof layer or compact umbrella');
    if (wind) layers.add('a wind-resistant outer layer');

    return '${AppStrings.assistantWearIntro(feels.round())} '
        '${layers.join('; ')}.${_footer(weather)}';
  }

  String _answerAirQuality(WeatherResult weather) {
    final p = weather.pollution;
    final aqi = p.usAqi;
    if (aqi == null && p.pm2_5 == null && p.pm10 == null) {
      return '${AppStrings.aqiUnavailable}${_footer(weather)}';
    }
    final buffer = StringBuffer();
    if (aqi != null) {
      buffer.write('US AQI is $aqi. ');
      if (aqi <= 50) {
        buffer.write('Air looks good for most outdoor plans.');
      } else if (aqi <= 100) {
        buffer.write('Acceptable for most people; sensitive groups may notice it.');
      } else if (aqi <= 150) {
        buffer.write('Sensitive groups should limit long outdoor exertion.');
      } else {
        buffer.write('Consider reducing prolonged outdoor activity.');
      }
    }
    if (p.pm2_5 != null) buffer.write(' PM2.5: ${p.pm2_5!.round()} µg/m³.');
    if (p.pm10 != null) buffer.write(' PM10: ${p.pm10!.round()} µg/m³.');
    return '${buffer.toString().trim()}${_footer(weather)}';
  }

  String _answerWeekOutlook(WeatherResult weather) {
    final daily = weather.daily;
    if (daily.isEmpty) return _answerSummary(weather);

    final dayFmt = DateFormat.E();
    final lines = <String>['Here is your 7-day snapshot:'];
    for (var i = 0; i < daily.length && i < 7; i++) {
      final d = daily[i];
      final label = i == 0 ? 'Today' : dayFmt.format(DateTime.parse(d.date));
      final rain = d.precipProbabilityMax;
      final rainBit = rain != null ? ', rain up to $rain%' : '';
      lines.add(
        '• $label: ${d.minTemp.round()}°–${d.maxTemp.round()}°, '
        '${dailyConditionLabel(d.weatherCode)}$rainBit',
      );
    }
    return '${lines.join('\n')}${_footer(weather)}';
  }

  String _answerTomorrow(WeatherResult weather) {
    if (weather.daily.length < 2) {
      return '${AppStrings.assistantNoTomorrow}${_footer(weather)}';
    }
    final d = weather.daily[1];
    final rain = d.precipProbabilityMax;
    final rainText = rain != null ? ' Rain chance up to $rain%.' : '';
    return 'Tomorrow in ${weather.location.name}: ${d.minTemp.round()}°–${d.maxTemp.round()}°, '
        '${dailyConditionLabel(d.weatherCode)}.$rainText'
        '${_footer(weather)}';
  }

  String _answerWind(WeatherResult weather) {
    final c = weather.current;
    final dir = c.windDirectionDegrees != null
        ? ' from ${windCompass(c.windDirectionDegrees!)}'
        : '';
    String note;
    if (c.windSpeed >= 30) {
      note = 'It will feel quite windy—secure loose items outdoors.';
    } else if (c.windSpeed >= 15) {
      note = 'Expect a noticeable breeze.';
    } else {
      note = 'Wind should stay relatively light.';
    }
    return 'Wind is ${c.windSpeed.round()} km/h$dir. $note${_footer(weather)}';
  }

  String _answerUv(WeatherResult weather) {
    final uv = weather.current.uvIndex;
    if (uv == null) {
      final max = weather.daily.isNotEmpty ? weather.daily.first.uvIndexMax : null;
      if (max == null) {
        return '${AppStrings.assistantNoUv}${_footer(weather)}';
      }
      return 'Daily UV max is about ${max.toStringAsFixed(1)} (${uvIndexLabel(max)}).${_footer(weather)}';
    }
    return 'Current UV is ${uvIndexLabel(uv)}. ${_uvAdvice(uv)}${_footer(weather)}';
  }

  String _uvAdvice(double uv) {
    if (uv < 3) return 'Minimal sun protection needed for short outings.';
    if (uv < 6) return 'Sunscreen helps if you are outside for a while.';
    if (uv < 8) return 'Use shade, sunscreen, and a hat around midday.';
    return 'Limit direct sun and use strong protection.';
  }

  String _answerTemperature(WeatherResult weather) {
    final c = weather.current;
    return 'Right now it is ${c.temperature.round()}° (feels like ${c.feelsLike.round()}°) '
        'with ${weatherLabel(c.weatherCode).toLowerCase()} conditions and '
        '${c.humidity}% humidity.${_footer(weather)}';
  }
}
