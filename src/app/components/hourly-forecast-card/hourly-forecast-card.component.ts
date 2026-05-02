import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { HourForecast } from '../../weather.models';
import { TranslatePipe } from '../../pipes/translate.pipe';

export interface HourlyChartPoint {
  x: number;
  y: number;
  temp: number;
}

export interface HourlyChartModel {
  width: number;
  height: number;
  padBottom: number;
  points: HourlyChartPoint[];
  linePoints: string;
  areaPath: string;
  yTicks: { y: number; label: string }[];
  xTicks: { x: number; hourIndex: number }[];
  minObserved: number;
  maxObserved: number;
  meanTemp: number;
  avgHumidity: number | null;
}

@Component({
  selector: 'app-hourly-forecast-card',
  standalone: true,
  imports: [CommonModule, TranslatePipe],
  templateUrl: './hourly-forecast-card.component.html',
  styleUrls: ['./hourly-forecast-card.component.scss'],
})
export class HourlyForecastCardComponent {
  @Input({ required: true }) hourlyData: HourForecast[] = [];

  readonly gradientId =
    typeof crypto !== 'undefined' && 'randomUUID' in crypto
      ? `hourly-temp-${crypto.randomUUID()}`
      : `hourly-temp-${Math.random().toString(36).slice(2, 11)}`;

  private readonly layout = {
    width: 640,
    height: 228,
    padLeft: 44,
    padRight: 14,
    padTop: 12,
    padBottom: 52,
  };

  chartModel(): HourlyChartModel | null {
    const data = this.hourlyData;
    if (!data.length) {
      return null;
    }

    const { width: w, height: h, padLeft, padRight, padTop, padBottom } = this.layout;
    const innerW = w - padLeft - padRight;
    const innerH = h - padTop - padBottom;
    const temps = data.map((d) => d.temperature);
    let minT = Math.min(...temps);
    let maxT = Math.max(...temps);
    if (maxT === minT) {
      minT -= 1;
      maxT += 1;
    }
    const span = maxT - minT;
    const pad = span * 0.08;
    const scaleMin = minT - pad;
    const scaleMax = maxT + pad;
    const range = Math.max(1e-9, scaleMax - scaleMin);
    const n = data.length;

    const xAt = (i: number): number => {
      if (n <= 1) {
        return padLeft + innerW / 2;
      }
      return padLeft + (i / (n - 1)) * innerW;
    };

    const yAt = (temp: number): number => padTop + innerH - ((temp - scaleMin) / range) * innerH;

    const points: HourlyChartPoint[] = data.map((d, i) => ({
      x: xAt(i),
      y: yAt(d.temperature),
      temp: d.temperature,
    }));

    const linePoints = points.map((p) => `${p.x},${p.y}`).join(' ');
    const baseline = h - padBottom;
    const first = points[0];
    const last = points[points.length - 1];
    const areaPath = [
      `M ${first.x} ${baseline}`,
      `L ${first.x} ${first.y}`,
      ...points.slice(1).map((p) => `L ${p.x} ${p.y}`),
      `L ${last.x} ${baseline}`,
      'Z',
    ].join(' ');

    const yTicks = [scaleMax, (scaleMax + scaleMin) / 2, scaleMin].map((tVal) => ({
      y: yAt(tVal),
      label: Math.round(tVal).toString(),
    }));

    const meanTemp = temps.reduce((a, b) => a + b, 0) / temps.length;

    const humidities = data
      .map((d) => d.relativeHumidity)
      .filter((v): v is number => v !== null && Number.isFinite(v));
    const avgHumidity =
      humidities.length > 0 ? humidities.reduce((a, b) => a + b, 0) / humidities.length : null;

    const tickSlots = Math.min(6, Math.max(2, n));
    const hourIndices: number[] = [];
    for (let k = 0; k < tickSlots; k++) {
      hourIndices.push(k === tickSlots - 1 ? n - 1 : Math.round((k / (tickSlots - 1)) * (n - 1)));
    }
    const xTicks: { x: number; hourIndex: number }[] = [...new Set(hourIndices)]
      .sort((a, b) => a - b)
      .map((hourIndex) => ({ x: xAt(hourIndex), hourIndex }));

    return {
      width: w,
      height: h,
      padBottom,
      points,
      linePoints,
      areaPath,
      yTicks,
      xTicks,
      minObserved: Math.min(...temps),
      maxObserved: Math.max(...temps),
      meanTemp,
      avgHumidity,
    };
  }

  precipBarPx(h: HourForecast): number {
    const p = h.precipitationProbability ?? 0;
    if (p <= 0) {
      return 2;
    }
    return Math.round(4 + (p / 100) * 34);
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
