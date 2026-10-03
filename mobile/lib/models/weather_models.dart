class LocationOption {
  const LocationOption({
    this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final int? id;
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  String get displayName => '$name, $country';

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: json['id'] as int?,
      name: json['name'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

const _coordMatchEps = 1e-3;

bool locationsMatch(LocationOption a, LocationOption b) {
  if (a.id != null && b.id != null && a.id == b.id) {
    return true;
  }
  return (a.latitude - b.latitude).abs() < _coordMatchEps &&
      (a.longitude - b.longitude).abs() < _coordMatchEps;
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirectionDegrees,
    required this.weatherCode,
    required this.time,
    required this.pressureMsl,
    required this.cloudCoverPercent,
    required this.dewPoint,
    required this.precipitationMm,
    required this.uvIndex,
  });

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double? windDirectionDegrees;
  final int weatherCode;
  final String time;
  final double? pressureMsl;
  final int? cloudCoverPercent;
  final double? dewPoint;
  final double? precipitationMm;
  final double? uvIndex;
}

class HourForecast {
  const HourForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.relativeHumidity,
  });

  final String time;
  final double temperature;
  final int weatherCode;
  final int? precipitationProbability;
  final int? relativeHumidity;
}

class DayForecast {
  const DayForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherCode,
    required this.precipProbabilityMax,
    required this.uvIndexMax,
    required this.windSpeedMax,
    required this.sunrise,
    required this.sunset,
  });

  final String date;
  final double minTemp;
  final double maxTemp;
  final int weatherCode;
  final int? precipProbabilityMax;
  final double? uvIndexMax;
  final double? windSpeedMax;
  final String? sunrise;
  final String? sunset;
}

class PollutionData {
  const PollutionData({
    required this.usAqi,
    required this.pm10,
    required this.pm2_5,
    required this.carbonMonoxide,
    required this.nitrogenDioxide,
    required this.ozone,
  });

  final int? usAqi;
  final double? pm10;
  final double? pm2_5;
  final double? carbonMonoxide;
  final double? nitrogenDioxide;
  final double? ozone;
}

class WeatherResult {
  const WeatherResult({
    required this.locationName,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.current,
    required this.pollution,
    required this.hourly,
    required this.daily,
  });

  final String locationName;
  final LocationOption location;
  final double latitude;
  final double longitude;
  final CurrentWeather current;
  final PollutionData pollution;
  final List<HourForecast> hourly;
  final List<DayForecast> daily;

  WeatherResult copyWith({LocationOption? location, String? locationName}) {
    return WeatherResult(
      locationName: locationName ?? this.locationName,
      location: location ?? this.location,
      latitude: latitude,
      longitude: longitude,
      current: current,
      pollution: pollution,
      hourly: hourly,
      daily: daily,
    );
  }
}
