import { LocationOption, WeatherResult } from '../app/weather.models';

export function makeLocation(overrides: Partial<LocationOption> = {}): LocationOption {
  return {
    id: 999001,
    name: 'Test City',
    country: 'TC',
    latitude: 12.97,
    longitude: 77.59,
    ...overrides,
  };
}

/** Minimal Open-Meteo-style forecast payload (5 daily rows, 24+ hourly steps). */
export function forecastJson(weatherCode = 0) {
  const hourlyTimes = Array.from({ length: 24 }, (_, i) => `2025-01-01T${String(i).padStart(2, '0')}:00`);
  const temps = hourlyTimes.map(() => 20);
  const codes = hourlyTimes.map(() => weatherCode);
  const probs = hourlyTimes.map(() => 10);
  const hums = hourlyTimes.map(() => 50);

  const dailyTimes = ['2025-01-01', '2025-01-02', '2025-01-03', '2025-01-04', '2025-01-05'];

  return {
    current: {
      time: '2025-01-01T12:00',
      temperature_2m: 22,
      apparent_temperature: 21,
      relative_humidity_2m: 55,
      wind_speed_10m: 10,
      wind_direction_10m: 90,
      weather_code: weatherCode,
      pressure_msl: 1013,
      cloud_cover: 40,
      dew_point_2m: 12,
      precipitation: 0,
      uv_index: 3,
    },
    hourly: {
      time: hourlyTimes,
      temperature_2m: temps,
      weather_code: codes,
      precipitation_probability: probs,
      relative_humidity_2m: hums,
    },
    daily: {
      time: dailyTimes,
      temperature_2m_min: dailyTimes.map(() => 18),
      temperature_2m_max: dailyTimes.map(() => 26),
      weather_code: dailyTimes.map(() => weatherCode),
      precipitation_probability_max: dailyTimes.map(() => 20),
      uv_index_max: dailyTimes.map(() => 5),
      wind_speed_10m_max: dailyTimes.map(() => 15),
      sunrise: dailyTimes.map(() => '2025-01-01T06:30'),
      sunset: dailyTimes.map(() => '2025-01-01T18:30'),
    },
  };
}

export function airQualityJson() {
  return {
    current: {
      us_aqi: 42,
      pm10: 20,
      pm2_5: 15,
      carbon_monoxide: 100,
      nitrogen_dioxide: 30,
      ozone: 40,
    },
  };
}

/** Omits optional API fields to exercise nullish-coalescing branches in WeatherService. */
export function minimalForecastJson(weatherCode = 0) {
  const hourlyTimes = Array.from({ length: 24 }, (_, i) => `2025-01-01T${String(i).padStart(2, '0')}:00`);
  const dailyTimes = ['2025-01-01', '2025-01-02', '2025-01-03', '2025-01-04', '2025-01-05'];
  return {
    current: {
      time: '2025-01-01T12:00',
      temperature_2m: 22,
      apparent_temperature: 21,
      relative_humidity_2m: 55,
      wind_speed_10m: 10,
      weather_code: weatherCode,
    },
    hourly: {
      time: hourlyTimes,
      temperature_2m: hourlyTimes.map(() => 20),
      weather_code: hourlyTimes.map(() => weatherCode),
    },
    daily: {
      time: dailyTimes,
      temperature_2m_min: dailyTimes.map(() => 18),
      temperature_2m_max: dailyTimes.map(() => 26),
      weather_code: dailyTimes.map(() => weatherCode),
    },
  };
}

export function minimalAirQualityJson() {
  return { current: {} };
}

export function makeWeatherResult(overrides: Partial<WeatherResult> = {}): WeatherResult {
  const loc = makeLocation();
  const base: WeatherResult = {
    locationName: `${loc.name}, ${loc.country}`,
    location: loc,
    latitude: loc.latitude,
    longitude: loc.longitude,
    current: {
      time: '2025-01-01T12:00',
      temperature: 22,
      feelsLike: 21,
      humidity: 55,
      windSpeed: 10,
      windDirectionDegrees: 90,
      weatherCode: 0,
      pressureMsl: 1013,
      cloudCoverPercent: 40,
      dewPoint: 12,
      precipitationMm: 0,
      uvIndex: 3,
    },
    pollution: {
      usAqi: 42,
      pm10: 20,
      pm2_5: 15,
      carbonMonoxide: 100,
      nitrogenDioxide: 30,
      ozone: 40,
    },
    hourly: [],
    daily: [],
    ...overrides,
  };
  return base;
}
