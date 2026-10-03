import 'package:intl/intl.dart';

import '../models/weather_models.dart';
import 'weather_utils.dart';

/// Narrative dashboard insight from current, hourly, and daily data (no calendar dates).
String buildWeatherInsight(WeatherResult data) {
  final c = data.current;
  final hourly = data.hourly;
  final daily = data.daily;
  final parts = <String>[];

  parts.add(_openingParagraph(c));
  if (hourly.isNotEmpty) {
    parts.add(_hourlyParagraph(hourly, c));
  }
  if (daily.isNotEmpty) {
    parts.add(_outlookParagraph(daily));
  }
  final uvLine = _uvParagraph(c.uvIndex);
  if (uvLine != null) parts.add(uvLine);
  final airLine = _airQualityParagraph(data.pollution);
  if (airLine != null) parts.add(airLine);

  return parts.join(' ');
}

String _openingParagraph(CurrentWeather c) {
  final category = weatherCategoryKey(c.weatherCode);
  final temp = c.temperature.round();
  final feels = c.feelsLike.round();
  final delta = feels - temp;

  final String mood;
  switch (category) {
    case 'weather.clear':
      mood = 'Skies look mostly clear right now';
    case 'weather.cloudy':
      mood = 'Cloud cover is building in';
    case 'weather.rain':
      mood = 'Wet weather is in play';
    case 'weather.snow':
      mood = 'Cold and wintry conditions dominate';
    default:
      mood = 'Active or stormy weather is possible';
  }

  final comfort = delta.abs() <= 1
      ? 'and temperatures feel close to the reading'
      : delta > 0
          ? 'and it feels about ${delta.abs()}° warmer than the thermometer'
          : 'and it feels about ${delta.abs()}° cooler than the thermometer';

  final humidityNote = c.humidity >= 75
      ? ' Humidity is high, so the air may feel heavy.'
      : c.humidity <= 35
          ? ' Humidity is low, so the air may feel crisp and dry.'
          : '';

  return '$mood, with $temp° observed ($comfort).$humidityNote';
}

String _hourlyParagraph(List<HourForecast> hourly, CurrentWeather current) {
  final timeFmt = DateFormat('h a');

  HourForecast? warmest;
  HourForecast? rainiest;
  for (final h in hourly) {
    if (warmest == null || h.temperature > warmest.temperature) warmest = h;
    final p = h.precipitationProbability ?? 0;
    final best = rainiest?.precipitationProbability ?? 0;
    if (p > best) rainiest = h;
  }

  final first = hourly.first.temperature;
  final last = hourly.last.temperature;
  final trend = last - first;
  final trendText = trend.abs() < 1.5
      ? 'Temperatures should hold fairly steady over the next several hours'
      : trend > 0
          ? 'Temperatures should climb through the coming hours'
          : 'Temperatures should ease downward through the coming hours';

  final buffer = StringBuffer(trendText);
  if (warmest != null) {
    final t = DateTime.tryParse(warmest.time);
    final when = t != null ? ' around ${timeFmt.format(t.toLocal())}' : '';
    buffer.write(
      ', peaking near ${warmest.temperature.round()}°$when',
    );
  }
  buffer.write('.');

  final rainProb = rainiest?.precipitationProbability;
  if (rainProb != null && rainProb >= 25) {
    final t = rainiest!.time;
    final dt = DateTime.tryParse(t);
    final when = dt != null ? timeFmt.format(dt.toLocal()) : 'later';
    buffer.write(
      ' Rain chances are highest near $when ($rainProb% in the hourly window).',
    );
  } else if ((current.precipitationMm ?? 0) > 0.1) {
    buffer.write(' Light precipitation is already showing up in current conditions.');
  } else {
    buffer.write(' No strong hourly rain signals in the next stretch.');
  }

  if (current.windSpeed >= 25) {
    buffer.write(' Winds stay fairly brisk (${current.windSpeed.round()} km/h).');
  } else if (current.windSpeed >= 12) {
    buffer.write(' Expect a noticeable breeze (${current.windSpeed.round()} km/h).');
  }

  return buffer.toString();
}

String _outlookParagraph(List<DayForecast> daily) {
  final buffer = StringBuffer();

  final today = daily.first;
  final swing = today.maxTemp - today.minTemp;
  buffer.write(
    'Through today, expect a ${today.minTemp.round()}°–${today.maxTemp.round()}° range',
  );
  if (swing >= 12) {
    buffer.write(' with a wide day-night swing');
  } else if (swing <= 6) {
    buffer.write(' with a fairly stable day-night spread');
  }
  buffer.write('.');

  DayForecast? nextRain;
  var rainIndex = -1;
  for (var i = 0; i < daily.length; i++) {
    if ((daily[i].precipProbabilityMax ?? 0) >= 35) {
      nextRain = daily[i];
      rainIndex = i;
      break;
    }
  }

  if (nextRain != null && rainIndex >= 0) {
    buffer.write(
      ' ${_relativeDayPhrase(rainIndex)} brings the next meaningful rain chance'
      ' (up to ${nextRain.precipProbabilityMax}%).',
    );
  } else {
    buffer.write(' The short-range outlook stays mostly dry.');
  }

  if (daily.length >= 2) {
    final tomorrow = daily[1];
    final tempShift = tomorrow.maxTemp - today.maxTemp;
    if (tempShift.abs() >= 3) {
      buffer.write(
        tempShift > 0
            ? ' Tomorrow should run a few degrees warmer at the top of the range.'
            : ' Tomorrow should cool off slightly at the top of the range.',
      );
    }
  }

  final stormyDays = daily.where((d) => d.weatherCode >= 95).length;
  if (stormyDays > 0) {
    buffer.write(
      ' Keep an eye on thunder or storm risk in the extended outlook.',
    );
  }

  return buffer.toString().trim();
}

String _relativeDayPhrase(int index) {
  return switch (index) {
    0 => 'Later today',
    1 => 'Tomorrow',
    2 => 'The following day',
    _ => 'Further out',
  };
}

String? _uvParagraph(double? uv) {
  if (uv == null) return null;
  if (uv < 3) {
    return 'UV exposure is low—minimal sun protection needed for most people.';
  }
  if (uv < 6) {
    return 'UV is moderate; sunscreen helps if you are outside for a while.';
  }
  if (uv < 8) {
    return 'UV is high; shade, sunscreen, and a hat are smart if you are outdoors midday.';
  }
  return 'UV is very high; limit direct sun exposure and use strong protection.';
}

String? _airQualityParagraph(PollutionData pollution) {
  final aqi = pollution.usAqi;
  if (aqi == null) return null;
  if (aqi <= 50) {
    return 'Air quality looks good for outdoor activity.';
  }
  if (aqi <= 100) {
    return 'Air quality is acceptable; unusually sensitive people may notice it.';
  }
  if (aqi <= 150) {
    return 'Air quality is moderate—sensitive groups may want to shorten outdoor exertion.';
  }
  if (aqi <= 200) {
    return 'Air quality is unhealthy for sensitive groups; consider lighter outdoor plans.';
  }
  return 'Air quality is poor; limit prolonged outdoor exertion if you can.';
}

String uvIndexLabel(double? uv) {
  if (uv == null) return '—';
  final v = uv.round();
  String band;
  if (v <= 2) {
    band = 'Low';
  } else if (v <= 5) {
    band = 'Moderate';
  } else if (v <= 7) {
    band = 'High';
  } else if (v <= 10) {
    band = 'Very High';
  } else {
    band = 'Extreme';
  }
  return '$v ($band)';
}
