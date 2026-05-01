import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { forkJoin, map, Observable, switchMap } from 'rxjs';
import {
  DayForecast,
  HourForecast,
  LocationOption,
  PollutionData,
  WeatherResult,
} from '../weather.models';

interface GeocodingResponse {
  results?: Array<{
    name: string;
    country: string;
    latitude: number;
    longitude: number;
  }>;
}

interface ForecastResponse {
  current: {
    time: string;
    temperature_2m: number;
    apparent_temperature: number;
    relative_humidity_2m: number;
    wind_speed_10m: number;
    weather_code: number;
  };
  hourly: {
    time: string[];
    temperature_2m: number[];
    weather_code: number[];
  };
  daily: {
    time: string[];
    temperature_2m_min: number[];
    temperature_2m_max: number[];
    weather_code: number[];
  };
}

interface AirQualityResponse {
  current: {
    us_aqi?: number;
    pm10?: number;
    pm2_5?: number;
    carbon_monoxide?: number;
    nitrogen_dioxide?: number;
    ozone?: number;
  };
}

@Injectable({ providedIn: 'root' })
export class WeatherService {
  constructor(private readonly http: HttpClient) {}

  searchLocations(query: string): Observable<LocationOption[]> {
    const params = new URLSearchParams({
      name: query,
      count: '5',
      language: 'en',
      format: 'json',
    });

    return this.http
      .get<GeocodingResponse>(
        `https://geocoding-api.open-meteo.com/v1/search?${params.toString()}`
      )
      .pipe(
        map((response) =>
          (response.results ?? []).map((item) => ({
            name: item.name,
            country: item.country,
            latitude: item.latitude,
            longitude: item.longitude,
          }))
        )
      );
  }

  fetchWeather(location: LocationOption): Observable<WeatherResult> {
    const forecastParams = new URLSearchParams({
      latitude: location.latitude.toString(),
      longitude: location.longitude.toString(),
      current:
        'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code',
      hourly: 'temperature_2m,weather_code',
      daily: 'weather_code,temperature_2m_max,temperature_2m_min',
      forecast_days: '5',
      timezone: 'auto',
    });

    const airQualityParams = new URLSearchParams({
      latitude: location.latitude.toString(),
      longitude: location.longitude.toString(),
      current:
        'us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,ozone',
      timezone: 'auto',
    });

    return forkJoin({
      forecast: this.http.get<ForecastResponse>(
        `https://api.open-meteo.com/v1/forecast?${forecastParams.toString()}`
      ),
      airQuality: this.http.get<AirQualityResponse>(
        `https://air-quality-api.open-meteo.com/v1/air-quality?${airQualityParams.toString()}`
      ),
    }).pipe(
      map(({ forecast, airQuality }) => {
        const hourly: HourForecast[] = forecast.hourly.time.slice(0, 12).map((time, index) => ({
          time,
          temperature: forecast.hourly.temperature_2m[index],
          weatherCode: forecast.hourly.weather_code[index],
        }));

        const daily: DayForecast[] = forecast.daily.time.map((date, index) => ({
          date,
          minTemp: forecast.daily.temperature_2m_min[index],
          maxTemp: forecast.daily.temperature_2m_max[index],
          weatherCode: forecast.daily.weather_code[index],
        }));

        const pollution: PollutionData = {
          usAqi: airQuality.current.us_aqi ?? null,
          pm10: airQuality.current.pm10 ?? null,
          pm2_5: airQuality.current.pm2_5 ?? null,
          carbonMonoxide: airQuality.current.carbon_monoxide ?? null,
          nitrogenDioxide: airQuality.current.nitrogen_dioxide ?? null,
          ozone: airQuality.current.ozone ?? null,
        };

        return {
          locationName: `${location.name}, ${location.country}`,
          location,
          latitude: location.latitude,
          longitude: location.longitude,
          current: {
            time: forecast.current.time,
            temperature: forecast.current.temperature_2m,
            feelsLike: forecast.current.apparent_temperature,
            humidity: forecast.current.relative_humidity_2m,
            windSpeed: forecast.current.wind_speed_10m,
            weatherCode: forecast.current.weather_code,
          },
          pollution,
          hourly,
          daily,
        };
      })
    );
  }

  resolveAndFetchWeather(query: string): Observable<WeatherResult> {
    return this.searchLocations(query).pipe(
      map((locations) => {
        if (!locations.length) {
          throw new Error('No matching location found.');
        }
        return locations[0];
      }),
      switchMap((location) => this.fetchWeather(location))
    );
  }
}
