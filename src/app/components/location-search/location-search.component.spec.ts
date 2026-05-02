import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { LocationSearchComponent } from './location-search.component';
import { I18nService } from '../../services/i18n.service';
import { makeLocation, makeWeatherResult } from '../../../test-utils/weather-fixtures';

describe('LocationSearchComponent', () => {
  let fixture: ComponentFixture<LocationSearchComponent>;
  let comp: LocationSearchComponent;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LocationSearchComponent, ReactiveFormsModule],
      providers: [I18nService],
    }).compileComponents();
    fixture = TestBed.createComponent(LocationSearchComponent);
    comp = fixture.componentInstance;
    comp.cityControl = new FormControl('', { nonNullable: true });
    fixture.detectChanges();
  });

  it('emits search on button click', () => {
    const spy = spyOn(comp.search, 'emit');
    comp.cityControl.setValue('Paris');
    fixture.detectChanges();
    const btn = fixture.nativeElement.querySelector('button[type="button"]');
    btn.click();
    expect(spy).toHaveBeenCalledWith('Paris');
  });

  it('emits saveCurrent', () => {
    const spy = spyOn(comp.saveCurrent, 'emit');
    comp.currentWeather = makeWeatherResult();
    comp.currentLocationSaved = false;
    fixture.detectChanges();
    const buttons = fixture.nativeElement.querySelectorAll('button[type="button"]');
    buttons[buttons.length - 1].click();
    expect(spy).toHaveBeenCalled();
  });

  it('emits selectSuggestion when suggestion clicked', () => {
    const opt = makeLocation();
    comp.locationSuggestions = [opt];
    comp.cityControl.setValue('x');
    fixture.detectChanges();
    const spy = spyOn(comp.selectSuggestion, 'emit');
    fixture.nativeElement.querySelector('.suggestions li').click();
    expect(spy).toHaveBeenCalledWith(opt);
  });
});
