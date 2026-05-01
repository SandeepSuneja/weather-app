import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { PollutionData } from '../../weather.models';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-pollution-card',
  standalone: true,
  imports: [CommonModule, TranslatePipe],
  templateUrl: './pollution-card.component.html',
  styleUrls: ['./pollution-card.component.scss'],
})
export class PollutionCardComponent {
  @Input({ required: true }) pollution!: PollutionData;

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
