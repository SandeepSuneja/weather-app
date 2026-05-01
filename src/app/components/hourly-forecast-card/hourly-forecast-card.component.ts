import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { HourForecast } from '../../weather.models';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-hourly-forecast-card',
  standalone: true,
  imports: [CommonModule, TranslatePipe],
  templateUrl: './hourly-forecast-card.component.html',
  styleUrls: ['./hourly-forecast-card.component.scss'],
})
export class HourlyForecastCardComponent {
  @Input({ required: true }) hourlyData: HourForecast[] = [];

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
}
