import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../l10n/app_strings.dart';
import '../models/weather_chart_models.dart';
import '../models/weather_models.dart';

const _geoMatchDeg = 0.05;

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<LocationOption>> searchLocations(String query) {
    return _forwardGeocode(query, '5');
  }

  Future<WeatherResult> fetchWeather(
    LocationOption location, {
    bool skipLanguageResolve = false,
  }) async {
    final resolved = skipLanguageResolve
        ? location
        : await _resolveLocation(location);

    final forecastParams = {
      'latitude': resolved.latitude.toString(),
      'longitude': resolved.longitude.toString(),
      'current':
          'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,wind_direction_10m,weather_code,pressure_msl,cloud_cover,dew_point_2m,precipitation,uv_index',
      'hourly':
          'temperature_2m,apparent_temperature,weather_code,precipitation_probability,relative_humidity_2m,wind_speed_10m,precipitation,pressure_msl,cloud_cover,uv_index,dew_point_2m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max,wind_speed_10m_max,sunrise,sunset',
      'forecast_days': '7',
      'timezone': 'auto',
    };

    final airQualityParams = {
      'latitude': resolved.latitude.toString(),
      'longitude': resolved.longitude.toString(),
      'current': 'us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,ozone',
      'hourly': 'us_aqi,pm2_5,pm10',
      'timezone': 'auto',
    };

    final forecastUri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      forecastParams,
    );
    final airUri = Uri.https(
      'air-quality-api.open-meteo.com',
      '/v1/air-quality',
      airQualityParams,
    );

    final forecastResponse = await _client.get(forecastUri);
    if (forecastResponse.statusCode != 200) {
      debugPrint(
        '[Weatherly] forecast HTTP ${forecastResponse.statusCode}',
      );
      throw WeatherFetchException();
    }

    final forecast =
        jsonDecode(forecastResponse.body) as Map<String, dynamic>;

    Map<String, dynamic> airQuality = const {'current': <String, dynamic>{}};
    try {
      final airResponse = await _client.get(airUri);
      if (airResponse.statusCode == 200) {
        airQuality = jsonDecode(airResponse.body) as Map<String, dynamic>;
      } else {
        debugPrint('[Weatherly] air-quality HTTP ${airResponse.statusCode}');
      }
    } catch (e, st) {
      debugPrint('[Weatherly] air-quality request failed: $e\n$st');
    }

    return _mapWeatherResult(resolved, forecast, airQuality);
  }

  Future<WeatherResult> resolveAndFetchWeather(String query) async {
    final locations = await searchLocations(query);
    if (locations.isEmpty) {
      throw LocationNotFoundException();
    }
    return fetchWeather(locations.first);
  }

  Future<LocationOption> locationFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    final fromNominatim = await _reverseGeocodeNominatim(latitude, longitude);
    if (fromNominatim != null) {
      return _searchLocationsByNameNearCoords(fromNominatim);
    }
    return LocationOption(
      name: AppStrings.locationCurrent,
      country: AppStrings.locationNearby,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<WeatherResult> fetchWeatherForCoordinates(
    double latitude,
    double longitude,
  ) async {
    final coordOnly = LocationOption(
      name: AppStrings.locationCurrent,
      country: AppStrings.locationNearby,
      latitude: latitude,
      longitude: longitude,
    );

    try {
      final result = await fetchWeather(coordOnly, skipLanguageResolve: true);
      final labeled = await locationFromCoordinates(latitude, longitude);
      if (_isGpsPlaceholder(labeled)) {
        return result;
      }
      return result.copyWith(
        location: labeled,
        locationName: labeled.displayName,
      );
    } catch (e, st) {
      debugPrint('[Weatherly] fetchWeatherForCoordinates failed: $e\n$st');
      rethrow;
    }
  }

  WeatherResult _mapWeatherResult(
    LocationOption resolved,
    Map<String, dynamic> forecast,
    Map<String, dynamic> airQuality,
  ) {
    final current = forecast['current'] as Map<String, dynamic>;
    final hourly = forecast['hourly'] as Map<String, dynamic>;
    final daily = forecast['daily'] as Map<String, dynamic>;
    final aqCurrent =
        airQuality['current'] as Map<String, dynamic>? ?? const {};

    final hourlyTimes = (hourly['time'] as List).cast<String>();
    final hourlyTemps = (hourly['temperature_2m'] as List).cast<num>();
    final hourlyCodes = (hourly['weather_code'] as List).cast<int>();
    final hourlyPrecip = hourly['precipitation_probability'] as List?;
    final hourlyHumidity = hourly['relative_humidity_2m'] as List?;
    final hourlyApparent = hourly['apparent_temperature'] as List?;
    final hourlyWind = hourly['wind_speed_10m'] as List?;
    final hourlyPrecipMm = hourly['precipitation'] as List?;
    final hourlyPressure = hourly['pressure_msl'] as List?;
    final hourlyCloud = hourly['cloud_cover'] as List?;
    final hourlyUv = hourly['uv_index'] as List?;
    final hourlyDew = hourly['dew_point_2m'] as List?;

    final startHour = _hourlyWindowStartIndex(
      current['time'] as String,
      hourlyTimes,
    );
    const dashboardHourlyCount = 12;
    const chartHourlyCount = 48;
    final hourForecasts = <HourForecast>[];
    final chartHourly = <HourlyChartPoint>[];
    for (var j = 0; j < chartHourlyCount; j++) {
      final i = startHour + j;
      if (i >= hourlyTimes.length) break;
      final time = DateTime.parse(hourlyTimes[i]);
      if (j < dashboardHourlyCount) {
        hourForecasts.add(
          HourForecast(
            time: hourlyTimes[i],
            temperature: hourlyTemps[i].toDouble(),
            weatherCode: hourlyCodes[i],
            precipitationProbability: hourlyPrecip?[i] as int?,
            relativeHumidity: hourlyHumidity?[i] as int?,
          ),
        );
      }
      chartHourly.add(
        HourlyChartPoint(
          time: time,
          temperature: hourlyTemps[i].toDouble(),
          apparentTemperature: (hourlyApparent?[i] as num?)?.toDouble(),
          precipitationProbability: hourlyPrecip?[i] as int?,
          relativeHumidity: hourlyHumidity?[i] as int?,
          windSpeed: (hourlyWind?[i] as num?)?.toDouble(),
          precipitationMm: (hourlyPrecipMm?[i] as num?)?.toDouble(),
          pressureMsl: (hourlyPressure?[i] as num?)?.toDouble(),
          cloudCover: hourlyCloud?[i] as int?,
          uvIndex: (hourlyUv?[i] as num?)?.toDouble(),
          dewPoint: (hourlyDew?[i] as num?)?.toDouble(),
        ),
      );
    }

    final aqHourlyMap = airQuality['hourly'] as Map<String, dynamic>?;
    final airQualityHourly = _mapAirQualityHourly(aqHourlyMap, startHour, chartHourlyCount);

    final dailyTimes = (daily['time'] as List).cast<String>();
    final dailyMin = (daily['temperature_2m_min'] as List).cast<num>();
    final dailyMax = (daily['temperature_2m_max'] as List).cast<num>();
    final dailyCodes = (daily['weather_code'] as List).cast<int>();
    final dailyPrecip = daily['precipitation_probability_max'] as List?;
    final dailyUv = daily['uv_index_max'] as List?;
    final dailyWind = daily['wind_speed_10m_max'] as List?;
    final dailySunrise = daily['sunrise'] as List?;
    final dailySunset = daily['sunset'] as List?;

    final dayForecasts = <DayForecast>[];
    for (var i = 0; i < dailyTimes.length; i++) {
      dayForecasts.add(
        DayForecast(
          date: dailyTimes[i],
          minTemp: dailyMin[i].toDouble(),
          maxTemp: dailyMax[i].toDouble(),
          weatherCode: dailyCodes[i],
          precipProbabilityMax: dailyPrecip?[i] as int?,
          uvIndexMax: (dailyUv?[i] as num?)?.toDouble(),
          windSpeedMax: (dailyWind?[i] as num?)?.toDouble(),
          sunrise: dailySunrise?[i] as String?,
          sunset: dailySunset?[i] as String?,
        ),
      );
    }

    return WeatherResult(
      locationName: resolved.displayName,
      location: resolved,
      latitude: resolved.latitude,
      longitude: resolved.longitude,
      current: CurrentWeather(
        time: current['time'] as String,
        temperature: (current['temperature_2m'] as num).toDouble(),
        feelsLike: (current['apparent_temperature'] as num).toDouble(),
        humidity: current['relative_humidity_2m'] as int,
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        windDirectionDegrees:
            (current['wind_direction_10m'] as num?)?.toDouble(),
        weatherCode: current['weather_code'] as int,
        pressureMsl: (current['pressure_msl'] as num?)?.toDouble(),
        cloudCoverPercent: current['cloud_cover'] as int?,
        dewPoint: (current['dew_point_2m'] as num?)?.toDouble(),
        precipitationMm: (current['precipitation'] as num?)?.toDouble(),
        uvIndex: (current['uv_index'] as num?)?.toDouble(),
      ),
      pollution: PollutionData(
        usAqi: _readUsAqi(aqCurrent['us_aqi']),
        pm10: (aqCurrent['pm10'] as num?)?.toDouble(),
        pm2_5: (aqCurrent['pm2_5'] as num?)?.toDouble(),
        carbonMonoxide: (aqCurrent['carbon_monoxide'] as num?)?.toDouble(),
        nitrogenDioxide: (aqCurrent['nitrogen_dioxide'] as num?)?.toDouble(),
        ozone: (aqCurrent['ozone'] as num?)?.toDouble(),
      ),
      hourly: hourForecasts,
      daily: dayForecasts,
      charts: WeatherChartData(
        hourly: chartHourly,
        airQualityHourly: airQualityHourly,
      ),
    );
  }

  List<HourlyAirQualityPoint> _mapAirQualityHourly(
    Map<String, dynamic>? aqHourly,
    int startHour,
    int count,
  ) {
    if (aqHourly == null) return const [];
    final times = aqHourly['time'] as List?;
    if (times == null) return const [];
    final timeStrings = times.cast<String>();
    final aqiList = aqHourly['us_aqi'] as List?;
    final pm25 = aqHourly['pm2_5'] as List?;
    final pm10 = aqHourly['pm10'] as List?;

    final points = <HourlyAirQualityPoint>[];
    for (var j = 0; j < count; j++) {
      final i = startHour + j;
      if (i >= timeStrings.length) break;
      points.add(
        HourlyAirQualityPoint(
          time: DateTime.parse(timeStrings[i]),
          usAqi: _readUsAqi(aqiList?[i]),
          pm2_5: (pm25?[i] as num?)?.toDouble(),
          pm10: (pm10?[i] as num?)?.toDouble(),
        ),
      );
    }
    return points;
  }

  LocationOption _mapGeocodeToLocation(Map<String, dynamic> item) {
    return LocationOption(
      id: item['id'] as int?,
      name: item['name'] as String,
      country: item['country'] as String,
      latitude: (item['latitude'] as num).toDouble(),
      longitude: (item['longitude'] as num).toDouble(),
    );
  }

  Future<List<LocationOption>> _forwardGeocode(String name, String count) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': name,
      'count': count,
      'language': 'en',
      'format': 'json',
    });
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      return [];
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List? ?? [];
    return results
        .cast<Map<String, dynamic>>()
        .map(_mapGeocodeToLocation)
        .toList();
  }

  Future<LocationOption?> _getLocationById(int id) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/get', {
      'id': id.toString(),
      'language': 'en',
    });
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        return null;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['error'] == true || body['id'] == null) {
        return null;
      }
      return _mapGeocodeToLocation(body);
    } catch (_) {
      return null;
    }
  }

  Future<LocationOption> _searchLocationsByNameNearCoords(
    LocationOption location,
  ) async {
    final results = await _forwardGeocode(location.name, '20');
    if (results.isEmpty) {
      return location;
    }
    for (final r in results) {
      if ((r.latitude - location.latitude).abs() < _geoMatchDeg &&
          (r.longitude - location.longitude).abs() < _geoMatchDeg) {
        return r;
      }
    }
    return location;
  }

  Future<LocationOption> _resolveLocation(
    LocationOption location,
  ) async {
    if (location.id != null) {
      final resolved = await _getLocationById(location.id!);
      return resolved ?? location;
    }
    if (_isGpsPlaceholder(location)) {
      return locationFromCoordinates(location.latitude, location.longitude);
    }
    return _searchLocationsByNameNearCoords(location);
  }

  bool _isGpsPlaceholder(LocationOption location) {
    if (location.id != null) {
      return false;
    }
    return AppStrings.isGpsPlaceholderLocation(location.name, location.country);
  }

  Future<LocationOption?> _reverseGeocodeNominatim(
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'format': 'json',
      'addressdetails': '1',
      'accept-language': 'en',
    });
    try {
      final response = await _client.get(
        uri,
        headers: const {'User-Agent': 'WeatherlyMobile/1.0 (weather-app)'},
      );
      if (response.statusCode != 200) {
        return null;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final address = body['address'] as Map<String, dynamic>?;
      if (address == null) {
        return null;
      }
      final city = address['city'] as String? ??
          address['town'] as String? ??
          address['village'] as String? ??
          address['municipality'] as String? ??
          address['county'] as String? ??
          address['state_district'] as String?;
      final country = address['country'] as String? ?? '';
      if (city == null || city.isEmpty) {
        return null;
      }
      return LocationOption(
        name: city,
        country: country.isEmpty ? AppStrings.locationNearby : country,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('[Weatherly] Nominatim reverse geocode failed: $e');
      return null;
    }
  }
}

int? _readUsAqi(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return null;
}

/// Index of the hourly slot that matches [currentTimeIso] (Open-Meteo hour start).
int _hourlyWindowStartIndex(String currentTimeIso, List<String> hourlyTimes) {
  if (hourlyTimes.isEmpty) return 0;

  for (var i = 0; i < hourlyTimes.length; i++) {
    if (hourlyTimes[i] == currentTimeIso) return i;
  }

  final current = DateTime.parse(currentTimeIso);
  final currentHourStart = DateTime(
    current.year,
    current.month,
    current.day,
    current.hour,
  );

  for (var i = 0; i < hourlyTimes.length; i++) {
    final slot = DateTime.parse(hourlyTimes[i]);
    if (!slot.isBefore(currentHourStart)) return i;
  }

  return hourlyTimes.length - 1;
}

class WeatherFetchException implements Exception {}

class LocationNotFoundException implements Exception {}
