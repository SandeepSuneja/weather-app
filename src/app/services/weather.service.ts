import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { catchError, forkJoin, map, Observable, of, switchMap } from 'rxjs';
import { I18nService } from './i18n.service';
import {
  DayForecast,
  HourForecast,
  LocationOption,
  PollutionData,
  WeatherResult,
} from '../weather.models';

interface GeocodingResultItem {
  id: number;
  name: string;
  country: string;
  latitude: number;
  longitude: number;
}

interface GeocodingResponse {
  results?: GeocodingResultItem[];
}

interface GeocodingErrorBody {
  error?: boolean;
}

interface ForecastResponse {
  current: {
    time: string;
    temperature_2m: number;
    apparent_temperature: number;
    relative_humidity_2m: number;
    wind_speed_10m: number;
    wind_direction_10m?: number;
    weather_code: number;
    pressure_msl?: number;
    cloud_cover?: number;
    dew_point_2m?: number;
    precipitation?: number;
    uv_index?: number;
  };
  hourly: {
    time: string[];
    temperature_2m: number[];
    weather_code: number[];
    precipitation_probability?: number[];
    relative_humidity_2m?: number[];
  };
  daily: {
    time: string[];
    temperature_2m_min: number[];
    temperature_2m_max: number[];
    weather_code: number[];
    precipitation_probability_max?: number[];
    uv_index_max?: number[];
    wind_speed_10m_max?: number[];
    sunrise?: string[];
    sunset?: string[];
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

/** ~5 km — pick a forward-geocode hit that matches the known coordinates. */
const GEO_MATCH_DEG = 0.05;

@Injectable({ providedIn: 'root' })
export class WeatherService {
  constructor(
    private readonly http: HttpClient,
    private readonly i18n: I18nService
  ) {}

  searchLocations(query: string): Observable<LocationOption[]> {
    return this.forwardGeocode(query, '5');
  }

  /** Re-resolve city + country labels for the active UI language (same coordinates). */
  localizeWeatherLabels(result: WeatherResult): Observable<WeatherResult> {
    return this.resolveLocationForLanguage(result.location).pipe(
      map((loc) => ({
        ...result,
        location: loc,
        locationName: `${loc.name}, ${loc.country}`,
      }))
    );
  }

  fetchWeather(location: LocationOption): Observable<WeatherResult> {
    return this.resolveLocationForLanguage(location).pipe(
      switchMap((resolved) => {
        const forecastParams = new URLSearchParams({
          latitude: resolved.latitude.toString(),
          longitude: resolved.longitude.toString(),
          current:
            'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,wind_direction_10m,weather_code,pressure_msl,cloud_cover,dew_point_2m,precipitation,uv_index',
          hourly: 'temperature_2m,weather_code,precipitation_probability,relative_humidity_2m',
          daily:
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max,wind_speed_10m_max,sunrise,sunset',
          forecast_days: '5',
          timezone: 'auto',
        });

        const airQualityParams = new URLSearchParams({
          latitude: resolved.latitude.toString(),
          longitude: resolved.longitude.toString(),
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
              precipitationProbability:
                forecast.hourly.precipitation_probability?.[index] ?? null,
              relativeHumidity: forecast.hourly.relative_humidity_2m?.[index] ?? null,
            }));

            const daily: DayForecast[] = forecast.daily.time.map((date, index) => ({
              date,
              minTemp: forecast.daily.temperature_2m_min[index],
              maxTemp: forecast.daily.temperature_2m_max[index],
              weatherCode: forecast.daily.weather_code[index],
              precipProbabilityMax: forecast.daily.precipitation_probability_max?.[index] ?? null,
              uvIndexMax: forecast.daily.uv_index_max?.[index] ?? null,
              windSpeedMax: forecast.daily.wind_speed_10m_max?.[index] ?? null,
              sunrise: forecast.daily.sunrise?.[index] ?? null,
              sunset: forecast.daily.sunset?.[index] ?? null,
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
              locationName: `${resolved.name}, ${resolved.country}`,
              location: resolved,
              latitude: resolved.latitude,
              longitude: resolved.longitude,
              current: {
                time: forecast.current.time,
                temperature: forecast.current.temperature_2m,
                feelsLike: forecast.current.apparent_temperature,
                humidity: forecast.current.relative_humidity_2m,
                windSpeed: forecast.current.wind_speed_10m,
                windDirectionDegrees: forecast.current.wind_direction_10m ?? null,
                weatherCode: forecast.current.weather_code,
                pressureMsl: forecast.current.pressure_msl ?? null,
                cloudCoverPercent: forecast.current.cloud_cover ?? null,
                dewPoint: forecast.current.dew_point_2m ?? null,
                precipitationMm: forecast.current.precipitation ?? null,
                uvIndex: forecast.current.uv_index ?? null,
              },
              pollution,
              hourly,
              daily,
            };
          })
        );
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

  private mapGeocodeToLocation(item: GeocodingResultItem): LocationOption {
    return {
      id: item.id,
      name: item.name,
      country: item.country,
      latitude: item.latitude,
      longitude: item.longitude,
    };
  }

  private forwardGeocode(name: string, count: string): Observable<LocationOption[]> {
    const params = new URLSearchParams({
      name,
      count,
      language: this.i18n.language,
      format: 'json',
    });

    return this.http
      .get<GeocodingResponse>(
        `https://geocoding-api.open-meteo.com/v1/search?${params.toString()}`
      )
      .pipe(
        map((response) =>
          (response.results ?? []).map((item) => this.mapGeocodeToLocation(item))
        )
      );
  }

  private getLocationById(id: number): Observable<LocationOption | null> {
    const params = new URLSearchParams({
      id: String(id),
      language: this.i18n.language,
    });

    return this.http
      .get<GeocodingResultItem & GeocodingErrorBody>(
        `https://geocoding-api.open-meteo.com/v1/get?${params.toString()}`
      )
      .pipe(
        map((body) =>
          body?.error === true || body?.id == null ? null : this.mapGeocodeToLocation(body)
        ),
        catchError(() => of(null))
      );
  }

  private searchLocationsByNameNearCoords(location: LocationOption): Observable<LocationOption> {
    return this.forwardGeocode(location.name, '20').pipe(
      map((results) => {
        if (!results.length) {
          return location;
        }
        const match = results.find(
          (r) =>
            Math.abs(r.latitude - location.latitude) < GEO_MATCH_DEG &&
            Math.abs(r.longitude - location.longitude) < GEO_MATCH_DEG
        );
        return match ?? location;
      })
    );
  }

  private resolveLocationForLanguage(location: LocationOption): Observable<LocationOption> {
    if (location.id != null) {
      return this.getLocationById(location.id).pipe(
        map((resolved) => resolved ?? location)
      );
    }
    return this.searchLocationsByNameNearCoords(location);
  }
}
