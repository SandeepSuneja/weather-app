import { ComponentFixture, TestBed } from '@angular/core/testing';
import { DailyForecastCardComponent } from './daily-forecast-card.component';
import { DayForecast } from '../../weather.models';

describe('DailyForecastCardComponent', () => {
  let fixture: ComponentFixture<DailyForecastCardComponent>;
  let comp: DailyForecastCardComponent;

  const days: DayForecast[] = [
    {
      date: '2025-01-01',
      minTemp: 10,
      maxTemp: 20,
      weatherCode: 0,
      precipProbabilityMax: 10,
      uvIndexMax: 1,
      windSpeedMax: 5,
      sunrise: null,
      sunset: null,
    },
    {
      date: '2025-01-02',
      minTemp: 12,
      maxTemp: 22,
      weatherCode: 2,
      precipProbabilityMax: null,
      uvIndexMax: null,
      windSpeedMax: null,
      sunrise: null,
      sunset: null,
    },
  ];

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DailyForecastCardComponent],
    }).compileComponents();
    fixture = TestBed.createComponent(DailyForecastCardComponent);
    comp = fixture.componentInstance;
    fixture.componentRef.setInput('dailyData', days);
    fixture.detectChanges();
  });

  it('weekColdHot when empty', () => {
    fixture.componentRef.setInput('dailyData', []);
    expect(comp.weekColdHot).toEqual({ min: 0, max: 1 });
  });

  it('weekColdHot from data', () => {
    expect(comp.weekColdHot.min).toBe(10);
    expect(comp.weekColdHot.max).toBe(22);
  });

  it('bandStyle uses span', () => {
    const style = comp.bandStyle(days[0]);
    expect(style.marginLeft).toContain('%');
    expect(style.width).toContain('%');
  });

  it('bandStyle widens narrow bands', () => {
    fixture.componentRef.setInput('dailyData', [
      { ...days[0], minTemp: 10, maxTemp: 10.1 },
    ]);
    const style = comp.bandStyle(fixture.componentInstance.dailyData[0]);
    expect(parseFloat(style.width)).toBeGreaterThanOrEqual(5);
  });

  it('bandStyle uses span fallback when week min equals max', () => {
    const flat: DayForecast[] = [
      { ...days[0], minTemp: 15, maxTemp: 15 },
      { ...days[1], minTemp: 15, maxTemp: 15 },
    ];
    fixture.componentRef.setInput('dailyData', flat);
    const style = comp.bandStyle(flat[0]);
    expect(style.marginLeft).toContain('%');
  });

  it('weatherLabel and weatherIcon', () => {
    expect(comp.weatherLabel(0)).toBe('weather.clear');
    expect(comp.weatherLabel(3)).toBe('weather.cloudy');
    expect(comp.weatherLabel(50)).toBe('weather.rain');
    expect(comp.weatherLabel(70)).toBe('weather.snow');
    expect(comp.weatherLabel(90)).toBe('weather.storm');
    expect(comp.weatherIcon(0)).toBe('☀️');
    expect(comp.weatherIcon(3)).toBe('⛅');
    expect(comp.weatherIcon(50)).toBe('🌧️');
    expect(comp.weatherIcon(70)).toBe('❄️');
    expect(comp.weatherIcon(90)).toBe('🌩️');
  });
});
