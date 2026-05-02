import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PollutionCardComponent } from './pollution-card.component';
import { I18nService } from '../../services/i18n.service';

describe('PollutionCardComponent', () => {
  let fixture: ComponentFixture<PollutionCardComponent>;
  let comp: PollutionCardComponent;

  const pollution = {
    usAqi: 42,
    pm10: 20,
    pm2_5: 15,
    carbonMonoxide: 100,
    nitrogenDioxide: 30,
    ozone: 40,
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PollutionCardComponent],
      providers: [I18nService],
    }).compileComponents();
    fixture = TestBed.createComponent(PollutionCardComponent);
    comp = fixture.componentInstance;
    fixture.componentRef.setInput('pollution', pollution);
    fixture.detectChanges();
  });

  it('aqiStatus and aqiClass', () => {
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
    expect(comp.aqiStatus(400)).toBe('aqi.hazardous');
    expect(comp.aqiClass(400)).toBe('hazardous');
  });

  it('metricPercent', () => {
    expect(comp.metricPercent(null, 100)).toBe(0);
    expect(comp.metricPercent(50, 100)).toBe(50);
  });
});
