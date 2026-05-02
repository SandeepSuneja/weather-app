/** GeoNames id from Open-Meteo geocoding; used to re-fetch localized labels. */
export interface LocationOption {
  id?: number;
  name: string;
  country: string;
  latitude: number;
  longitude: number;
}

const COORD_MATCH_EPS = 1e-3;

/** Same physical place: matching ids, or coordinates within ~100 m. */
export function locationsMatch(a: LocationOption, b: LocationOption): boolean {
  if (a.id != null && b.id != null && a.id === b.id) {
    return true;
  }
  return (
    Math.abs(a.latitude - b.latitude) < COORD_MATCH_EPS &&
    Math.abs(a.longitude - b.longitude) < COORD_MATCH_EPS
  );
}

export interface CurrentWeather {
  temperature: number;
  feelsLike: number;
  humidity: number;
  windSpeed: number;
  windDirectionDegrees: number | null;
  weatherCode: number;
  time: string;
  pressureMsl: number | null;
  cloudCoverPercent: number | null;
  dewPoint: number | null;
  precipitationMm: number | null;
  uvIndex: number | null;
}

export interface HourForecast {
  time: string;
  temperature: number;
  weatherCode: number;
  precipitationProbability: number | null;
  relativeHumidity: number | null;
}

export interface DayForecast {
  date: string;
  minTemp: number;
  maxTemp: number;
  weatherCode: number;
  precipProbabilityMax: number | null;
  uvIndexMax: number | null;
  windSpeedMax: number | null;
  sunrise: string | null;
  sunset: string | null;
}

export interface WeatherResult {
  locationName: string;
  location: LocationOption;
  latitude: number;
  longitude: number;
  current: CurrentWeather;
  pollution: PollutionData;
  hourly: HourForecast[];
  daily: DayForecast[];
}

export interface PollutionData {
  usAqi: number | null;
  pm10: number | null;
  pm2_5: number | null;
  carbonMonoxide: number | null;
  nitrogenDioxide: number | null;
  ozone: number | null;
}
