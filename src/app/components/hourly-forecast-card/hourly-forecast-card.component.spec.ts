import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HourlyForecastCardComponent } from './hourly-forecast-card.component';
import { HourForecast } from '../../weather.models';

function hourWithOptionalPrecip(
  base: HourForecast,
  precip: number | null | undefined
): HourForecast {
  return { ...base, precipitationProbability: precip as number | null };
}

describe('HourlyForecastCardComponent', () => {
  let fixture: ComponentFixture<HourlyForecastCardComponent>;
  let comp: HourlyForecastCardComponent;
  const origCrypto = globalThis.crypto;

  function hours(count: number, temp = 20): HourForecast[] {
    return Array.from({ length: count }, (_, i) => ({
      time: `2025-01-01T${String(i).padStart(2, '0')}:00`,
      temperature: temp,
      weatherCode: 0,
      precipitationProbability: i % 2 === 0 ? 0 : 50,
      relativeHumidity: 60,
    }));
  }

  beforeEach(async () => {
    Object.defineProperty(globalThis, 'crypto', {
      configurable: true,
      value: { ...origCrypto, randomUUID: () => 'test-uuid' },
    });
    await TestBed.configureTestingModule({
      imports: [HourlyForecastCardComponent],
    }).compileComponents();
    fixture = TestBed.createComponent(HourlyForecastCardComponent);
    comp = fixture.componentInstance;
  });

  afterEach(() => {
    Object.defineProperty(globalThis, 'crypto', { configurable: true, value: origCrypto });
  });

  it('chartModel returns null when empty', () => {
    fixture.componentRef.setInput('hourlyData', []);
    expect(comp.chartModel()).toBeNull();
  });

  it('chartModel builds for multiple hours', () => {
    fixture.componentRef.setInput('hourlyData', hours(12));
    const m = comp.chartModel();
    expect(m).not.toBeNull();
    expect(m!.points.length).toBe(12);
    expect(m!.linePoints).toContain(',');
    expect(m!.areaPath).toContain('M');
    expect(m!.avgHumidity).toBe(60);
  });

  it('chartModel expands equal temperatures', () => {
    fixture.componentRef.setInput('hourlyData', hours(3, 20));
    const m = comp.chartModel()!;
    expect(m.minObserved).toBe(20);
    expect(m.maxObserved).toBe(20);
    expect(m.yTicks.length).toBe(3);
  });

  it('chartModel skips equal-temp expansion when range already varies', () => {
    const data = hours(4, 20).map((h, i) => ({ ...h, temperature: 20 + i }));
    fixture.componentRef.setInput('hourlyData', data);
    const m = comp.chartModel()!;
    expect(m.minObserved).toBe(20);
    expect(m.maxObserved).toBe(23);
  });

  it('chartModel yields null avgHumidity when all humidities missing', () => {
    const data = hours(3).map((h) => ({ ...h, relativeHumidity: null }));
    fixture.componentRef.setInput('hourlyData', data);
    expect(comp.chartModel()!.avgHumidity).toBeNull();
  });

  it('chartModel single point centers x', () => {
    fixture.componentRef.setInput('hourlyData', hours(1));
    const m = comp.chartModel()!;
    expect(m.points.length).toBe(1);
    expect(m.xTicks.length).toBeGreaterThan(0);
  });

  it('chartModel averages humidity only from finite values', () => {
    const data: HourForecast[] = [
      {
        time: '2025-01-01T00:00',
        temperature: 10,
        weatherCode: 0,
        precipitationProbability: null,
        relativeHumidity: null,
      },
      {
        time: '2025-01-01T01:00',
        temperature: 12,
        weatherCode: 0,
        precipitationProbability: null,
        relativeHumidity: 80,
      },
    ];
    fixture.componentRef.setInput('hourlyData', data);
    expect(comp.chartModel()!.avgHumidity).toBe(80);
  });

  it('precipBarPx', () => {
    expect(comp.precipBarPx({ ...hours(1)[0], precipitationProbability: 0 })).toBe(2);
    expect(comp.precipBarPx({ ...hours(1)[0], precipitationProbability: 100 })).toBe(38);
    expect(comp.precipBarPx(hourWithOptionalPrecip(hours(1)[0], undefined))).toBe(2);
  });

  it('weatherIcon ranges', () => {
    expect(comp.weatherIcon(0)).toBe('☀️');
    expect(comp.weatherIcon(3)).toBe('⛅');
    expect(comp.weatherIcon(40)).toBe('🌧️');
    expect(comp.weatherIcon(70)).toBe('❄️');
    expect(comp.weatherIcon(90)).toBe('🌩️');
  });

  it('gradientId uses Math.random when randomUUID missing', () => {
    Object.defineProperty(globalThis, 'crypto', {
      configurable: true,
      value: {},
    });
    const f = TestBed.createComponent(HourlyForecastCardComponent);
    expect(f.componentInstance.gradientId).toMatch(/^hourly-temp-/);
    Object.defineProperty(globalThis, 'crypto', { configurable: true, value: origCrypto });
  });
});
