import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { WeatherResult } from '../../weather.models';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-current-weather-card',
  standalone: true,
  imports: [CommonModule, TranslatePipe],
  templateUrl: './current-weather-card.component.html',
  styleUrls: ['./current-weather-card.component.scss'],
})
export class CurrentWeatherCardComponent {
  @Input({ required: true }) weatherData!: WeatherResult;

  private static readonly WIND_COMPASS = [
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
  ] as const;

  windCompass(degrees: number | null): string {
    if (degrees === null || !Number.isFinite(degrees)) {
      return '';
    }
    const i = Math.round(degrees / 22.5) % 16;
    return `${CurrentWeatherCardComponent.WIND_COMPASS[i]} (${Math.round(degrees)}°)`;
  }

  weatherIcon(code: number): string {
    if (code === 0) {
      return '☀️';
    }
    if (code <= 3) {
      return '⛅';
    }
    if (code <= 67) {
      return '🌧️';
    }
    if (code <= 77) {
      return '❄️';
    }
    return '🌩️';
  }

  weatherLabel(code: number): string {
    if (code === 0) {
      return 'weather.clear';
    }
    if (code <= 3) {
      return 'weather.cloudy';
    }
    if (code <= 67) {
      return 'weather.rain';
    }
    if (code <= 77) {
      return 'weather.snow';
    }
    return 'weather.storm';
  }

  aqiStatus(value: number | null): string {
    if (value === null) {
      return 'aqi.unavailable';
    }
    if (value <= 50) {
      return 'aqi.good';
    }
    if (value <= 100) {
      return 'aqi.moderate';
    }
    if (value <= 150) {
      return 'aqi.sensitive';
    }
    if (value <= 200) {
      return 'aqi.unhealthy';
    }
    return 'aqi.hazardous';
  }

  aqiClass(value: number | null): string {
    if (value === null) {
      return 'neutral';
    }
    if (value <= 50) {
      return 'good';
    }
    if (value <= 100) {
      return 'moderate';
    }
    if (value <= 150) {
      return 'sensitive';
    }
    if (value <= 200) {
      return 'unhealthy';
    }
    return 'hazardous';
  }

  metricPercent(value: number | null, max: number): number {
    if (value === null) {
      return 0;
    }
    return Math.max(0, Math.min(100, (value / max) * 100));
  }
}
