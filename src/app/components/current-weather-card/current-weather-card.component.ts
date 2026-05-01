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
}
