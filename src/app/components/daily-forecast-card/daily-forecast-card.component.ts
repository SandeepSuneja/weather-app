import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { DayForecast } from '../../weather.models';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-daily-forecast-card',
  standalone: true,
  imports: [CommonModule, TranslatePipe],
  templateUrl: './daily-forecast-card.component.html',
  styleUrls: ['./daily-forecast-card.component.scss'],
})
export class DailyForecastCardComponent {
  @Input({ required: true }) dailyData: DayForecast[] = [];

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
