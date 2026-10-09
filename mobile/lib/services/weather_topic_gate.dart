/// Heuristic gate: assistant only accepts weather-related questions (Phase 0).
abstract final class WeatherTopicGate {
  static const _weatherTerms = {
    'weather',
    'forecast',
    'temperature',
    'temp',
    'rain',
    'raining',
    'rainy',
    'snow',
    'storm',
    'thunder',
    'wind',
    'windy',
    'humidity',
    'uv',
    'sun',
    'sunny',
    'cloud',
    'cloudy',
    'fog',
    'haze',
    'aqi',
    'air quality',
    'pollution',
    'pollen',
    'outside',
    'outdoor',
    'umbrella',
    'jacket',
    'coat',
    'layers',
    'wear',
    'clothes',
    'dress',
    'run',
    'jog',
    'walk',
    'hike',
    'exercise',
    'bike',
    'cycling',
    'today',
    'tonight',
    'tomorrow',
    'morning',
    'afternoon',
    'evening',
    'weekend',
    'week',
    'hourly',
    'feels like',
    'feels-like',
    'chill',
    'cold',
    'hot',
    'warm',
    'cool',
    'freeze',
    'heat',
    'dry',
    'wet',
    'precipitation',
    'drizzle',
    'shower',
    'sunrise',
    'sunset',
    'pressure',
    'visibility',
    'pm2',
    'pm10',
  };

  static bool isWeatherRelated(String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) return false;
    if (q.length <= 3 && q == 'uv') return true;

    for (final term in _weatherTerms) {
      if (q.contains(term)) return true;
    }

    // Short planning questions often omit "weather" explicitly.
    if (RegExp(r'^(should i|do i need|is it|will it|can i)\b').hasMatch(q)) {
      return RegExp(
        r'\b(umbrella|jacket|coat|outside|run|walk|shorts|sunglasses|sunscreen)\b',
      ).hasMatch(q);
    }

    return false;
  }
}
