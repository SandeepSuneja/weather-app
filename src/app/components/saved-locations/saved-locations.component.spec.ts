import { ComponentFixture, TestBed } from '@angular/core/testing';
import { SavedLocationsComponent } from './saved-locations.component';
import { I18nService } from '../../services/i18n.service';
import { makeLocation, makeWeatherResult } from '../../../test-utils/weather-fixtures';

describe('SavedLocationsComponent', () => {
  let fixture: ComponentFixture<SavedLocationsComponent>;
  let comp: SavedLocationsComponent;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SavedLocationsComponent],
      providers: [I18nService],
    }).compileComponents();
    fixture = TestBed.createComponent(SavedLocationsComponent);
    comp = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('weatherIcon branches', () => {
    expect(comp.weatherIcon(0)).toBe('☀️');
    expect(comp.weatherIcon(2)).toBe('⛅');
    expect(comp.weatherIcon(40)).toBe('🌧️');
    expect(comp.weatherIcon(70)).toBe('❄️');
    expect(comp.weatherIcon(90)).toBe('🌩️');
  });

  it('isSelected false when no selection', () => {
    comp.selectedLocation = null;
    expect(comp.isSelected(makeLocation())).toBeFalse();
  });

  it('isSelected uses locationsMatch', () => {
    const a = makeLocation({ id: 1, latitude: 10, longitude: 20 });
    const b = makeLocation({ id: 1, name: 'Other', country: 'Z', latitude: 10, longitude: 20 });
    comp.selectedLocation = a;
    expect(comp.isSelected(b)).toBeTrue();
  });
});
