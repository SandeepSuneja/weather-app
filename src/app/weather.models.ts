export interface LocationOption {
  name: string;
  country: string;
  latitude: number;
  longitude: number;
}

export interface CurrentWeather {
  temperature: number;
  feelsLike: number;
  humidity: number;
  windSpeed: number;
  weatherCode: number;
  time: string;
}

export interface HourForecast {
  time: string;
  temperature: number;
  weatherCode: number;
}

export interface DayForecast {
  date: string;
  minTemp: number;
  maxTemp: number;
  weatherCode: number;
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
