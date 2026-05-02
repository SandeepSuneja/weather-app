import { ComponentFixture, TestBed } from '@angular/core/testing';
import { CurrentWeatherCardComponent } from './current-weather-card.component';
import { makeWeatherResult } from '../../../test-utils/weather-fixtures';

describe('CurrentWeatherCardComponent', () => {
  let fixture: ComponentFixture<CurrentWeatherCardComponent>;
  let comp: CurrentWeatherCardComponent;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CurrentWeatherCardComponent],
    }).compileComponents();
    fixture = TestBed.createComponent(CurrentWeatherCardComponent);
    comp = fixture.componentInstance;
    fixture.componentRef.setInput('weatherData', makeWeatherResult());
    fixture.detectChanges();
  });

  it('windCompass handles null and non-finite', () => {
    expect(comp.windCompass(null)).toBe('');
    expect(comp.windCompass(Number.NaN)).toBe('');
  });

  it('windCompass formats direction', () => {
    expect(comp.windCompass(90)).toContain('E');
  });

  it('weatherIcon covers code ranges', () => {
    expect(comp.weatherIcon(0)).toBe('☀️');
    expect(comp.weatherIcon(2)).toBe('⛅');
    expect(comp.weatherIcon(50)).toBe('🌧️');
    expect(comp.weatherIcon(70)).toBe('❄️');
    expect(comp.weatherIcon(99)).toBe('🌩️');
  });

  it('weatherLabel maps to keys', () => {
    expect(comp.weatherLabel(0)).toBe('weather.clear');
    expect(comp.weatherLabel(2)).toBe('weather.cloudy');
    expect(comp.weatherLabel(50)).toBe('weather.rain');
    expect(comp.weatherLabel(70)).toBe('weather.snow');
    expect(comp.weatherLabel(99)).toBe('weather.storm');
  });

  it('aqiStatus and aqiClass branches', () => {
    expect(comp.aqiStatus(null)).toBe('aqi.unavailable');
    expect(comp.aqiClass(null)).toBe('neutral');
    expect(comp.aqiStatus(40)).toBe('aqi.good');
    expect(comp.aqiClass(40)).toBe('good');
    expect(comp.aqiStatus(80)).toBe('aqi.moderate');
    expect(comp.aqiClass(80)).toBe('moderate');
    expect(comp.aqiStatus(120)).toBe('aqi.sensitive');
    expect(comp.aqiClass(120)).toBe('sensitive');
    expect(comp.aqiStatus(180)).toBe('aqi.unhealthy');
    expect(comp.aqiClass(180)).toBe('unhealthy');
    expect(comp.aqiStatus(300)).toBe('aqi.hazardous');
    expect(comp.aqiClass(300)).toBe('hazardous');
  });

  it('metricPercent clamps', () => {
    expect(comp.metricPercent(null, 100)).toBe(0);
    expect(comp.metricPercent(50, 100)).toBe(50);
    expect(comp.metricPercent(200, 100)).toBe(100);
    expect(comp.metricPercent(-10, 100)).toBe(0);
  });
});
