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

  get weekColdHot(): { min: number; max: number } {
    if (!this.dailyData.length) {
      return { min: 0, max: 1 };
    }
    return {
      min: Math.min(...this.dailyData.map((d) => d.minTemp)),
      max: Math.max(...this.dailyData.map((d) => d.maxTemp)),
    };
  }

  bandStyle(day: DayForecast): { marginLeft: string; width: string } {
    const { min, max } = this.weekColdHot;
    const span = max - min || 1;
    const marginLeft = ((day.minTemp - min) / span) * 100;
    const width = ((day.maxTemp - day.minTemp) / span) * 100;
    return {
      marginLeft: `${marginLeft}%`,
      width: `${Math.max(5, width)}%`,
    };
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
