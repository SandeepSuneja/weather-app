import { provideHttpClient } from '@angular/common/http';
import { ComponentFixture, fakeAsync, TestBed, tick } from '@angular/core/testing';
import { provideAnimations } from '@angular/platform-browser/animations';
import { throwError, of } from 'rxjs';
import { AppComponent } from './app.component';
import { WeatherService } from './services/weather.service';
import { I18nService } from './services/i18n.service';
import { makeLocation, makeWeatherResult } from '../test-utils/weather-fixtures';
import { WeatherResult } from './weather.models';

type AppPrivateApi = {
  weatherLabel(code: number): string;
  localBackgroundForCode(code: number): { type: string; src: string } | null;
  applyWeatherTheme(code: number, locationName: string): void;
  getBackgroundUrl(condition: string, locationName: string): string;
  restoreSavedLocations(): void;
  loadSavedLocationWeather(): void;
};

describe('AppComponent', () => {
  let fixture: ComponentFixture<AppComponent>;
  let comp: AppComponent;
  let weatherStub: jasmine.SpyObj<WeatherService>;
  const storageKey = 'saved-weather-locations-v1';

  function stubWeatherDefaults() {
    weatherStub.resolveAndFetchWeather.and.returnValue(of(makeWeatherResult()));
    weatherStub.fetchWeather.and.returnValue(of(makeWeatherResult()));
    weatherStub.searchLocations.and.returnValue(of([]));
    weatherStub.localizeWeatherLabels.and.callFake((w: WeatherResult) =>
      of({ ...w, locationName: 'Loc', location: { ...w.location, name: 'Loc' } })
    );
  }

  beforeEach(async () => {
    localStorage.clear();
    weatherStub = jasmine.createSpyObj('WeatherService', [
      'resolveAndFetchWeather',
      'fetchWeather',
      'searchLocations',
      'localizeWeatherLabels',
    ]);
    stubWeatherDefaults();

    await TestBed.configureTestingModule({
      imports: [AppComponent],
      providers: [
        { provide: WeatherService, useValue: weatherStub },
        I18nService,
        provideAnimations(),
        provideHttpClient(),
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(AppComponent);
    comp = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('loads initial city via WeatherService', () => {
    expect(weatherStub.resolveAndFetchWeather).toHaveBeenCalledWith('Bengaluru');
  });

  it('fetchForCity returns early when empty', () => {
    weatherStub.resolveAndFetchWeather.calls.reset();
    comp.fetchForCity('   ');
    expect(weatherStub.resolveAndFetchWeather).not.toHaveBeenCalled();
  });

  it('fetchForCity handles error', () => {
    weatherStub.resolveAndFetchWeather.and.returnValue(throwError(() => new Error('fail')));
    comp.fetchForCity('X');
    expect(comp.error).toContain('Unable to fetch');
    expect(comp.loading).toBeFalse();
  });

  it('changeLanguage updates labels and reloads saved', () => {
    comp.changeLanguage('hi');
    expect(TestBed.inject(I18nService).language).toBe('hi');
    expect(weatherStub.localizeWeatherLabels).toHaveBeenCalled();
  });

  it('changeLanguage skips localize when no weather', () => {
    comp.weather = null;
    weatherStub.localizeWeatherLabels.calls.reset();
    comp.changeLanguage('ja');
    expect(weatherStub.localizeWeatherLabels).not.toHaveBeenCalled();
  });

  it('toggle and close saved panel sync body class', () => {
    comp.toggleSavedPanel();
    expect(comp.savedPanelOpen).toBeTrue();
    expect(document.body.classList.contains('app--saved-panel-open')).toBeTrue();
    comp.closeSavedPanel();
    expect(comp.savedPanelOpen).toBeFalse();
  });

  it('Escape closes saved panel', () => {
    comp.savedPanelOpen = true;
    comp.onDocumentKeydown(new KeyboardEvent('keydown', { key: 'Escape' }));
    expect(comp.savedPanelOpen).toBeFalse();
  });

  it('ngOnDestroy removes scroll lock class', () => {
    comp.savedPanelOpen = true;
    document.body.classList.add('app--saved-panel-open');
    comp.ngOnDestroy();
    expect(document.body.classList.contains('app--saved-panel-open')).toBeFalse();
  });

  it('selectSuggestion clears suggestions', () => {
    comp.locationSuggestions = [makeLocation()];
    comp.selectSuggestion(makeLocation());
    expect(comp.locationSuggestions.length).toBe(0);
  });

  it('addCurrentLocation skips without weather', () => {
    comp.weather = null;
    comp.addCurrentLocation();
    expect(comp.savedLocations.length).toBe(0);
  });

  it('addCurrentLocation persists new place', () => {
    comp.weather = makeWeatherResult();
    weatherStub.fetchWeather.calls.reset();
    comp.addCurrentLocation();
    expect(comp.savedLocations.length).toBe(1);
    expect(localStorage.getItem(storageKey)).toContain('Test City');
  });

  it('addCurrentLocation skips duplicate', () => {
    const w = makeWeatherResult();
    comp.weather = w;
    comp.savedLocations = [w.location];
    comp.addCurrentLocation();
    expect(comp.savedLocations.length).toBe(1);
  });

  it('removeLocation closes panel when last removed', () => {
    comp.savedPanelOpen = true;
    const loc = makeLocation();
    comp.savedLocations = [loc];
    comp.savedLocationWeather = [makeWeatherResult()];
    comp.removeLocation(loc);
    expect(comp.savedLocations.length).toBe(0);
    expect(comp.savedPanelOpen).toBeFalse();
  });

  it('openSavedLocation fetches and closes panel', () => {
    comp.savedPanelOpen = true;
    comp.openSavedLocation(makeLocation());
    expect(comp.savedPanelOpen).toBeFalse();
    expect(weatherStub.fetchWeather).toHaveBeenCalled();
  });

  it('isCurrentLocationSaved', () => {
    const w = makeWeatherResult();
    comp.weather = w;
    expect(comp.isCurrentLocationSaved()).toBeFalse();
    comp.savedLocations = [w.location];
    expect(comp.isCurrentLocationSaved()).toBeTrue();
  });

  it('private weather and background helpers', () => {
    const p = comp as unknown as AppPrivateApi;
    expect(p.weatherLabel(0)).toBe('clear');
    expect(p.weatherLabel(2)).toBe('cloudy');
    expect(p.weatherLabel(10)).toBe('rain');
    expect(p.weatherLabel(70)).toBe('snow');
    expect(p.weatherLabel(99)).toBe('storm');
    expect(p.localBackgroundForCode(Number.NaN)).toBeNull();
    expect(p.localBackgroundForCode(0)?.src).toContain('sunny');
    expect(p.localBackgroundForCode(1)?.src).toContain('rainbow');
    expect(p.localBackgroundForCode(2)?.type).toBe('gif');
    expect(p.localBackgroundForCode(10)?.src).toContain('rainy');
    expect(p.localBackgroundForCode(70)?.src).toContain('snowy');
    expect(p.localBackgroundForCode(80)?.src).toContain('thunderstorm');
    expect(p.localBackgroundForCode(-1)).toBeNull();
    expect(p.localBackgroundForCode(3.5)).toBeNull();
    expect(p.getBackgroundUrl('rain', 'Berlin, DE')).toContain('Berlin');
    p.applyWeatherTheme(3.5, 'Paris, FR');
    expect(comp.bgImageUrl).toContain('unsplash');
  });

  it('getBackgroundUrl falls back when leading CSV segment is empty', () => {
    const p = comp as unknown as AppPrivateApi;
    const url = p.getBackgroundUrl('cloudy', ',Berlin');
    expect(url).toContain(encodeURIComponent(',Berlin'));
  });

  it('restoreSavedLocations ignores invalid json', () => {
    localStorage.setItem(storageKey, 'not-json');
    const fresh = TestBed.createComponent(AppComponent).componentInstance;
    expect(fresh.savedLocations).toEqual([]);
  });

  it('restoreSavedLocations filters invalid rows', () => {
    localStorage.setItem(
      storageKey,
      JSON.stringify([{ name: 'A', country: 'B', latitude: 'bad', longitude: 1 }])
    );
    const fresh = TestBed.createComponent(AppComponent).componentInstance;
    expect(fresh.savedLocations.length).toBe(0);
  });

  it('loadSavedLocationWeather clears when no saved', () => {
    const p = comp as unknown as AppPrivateApi;
    comp.savedLocations = [];
    comp.savedLocationWeather = [makeWeatherResult()];
    p.loadSavedLocationWeather();
    expect(comp.savedLocationWeather).toEqual([]);
  });

  it('loadSavedLocationWeather handles error', () => {
    const p = comp as unknown as AppPrivateApi;
    comp.savedLocations = [makeLocation()];
    weatherStub.fetchWeather.and.returnValue(throwError(() => new Error('x')));
    p.loadSavedLocationWeather();
    expect(comp.error).toContain('saved locations');
    expect(comp.savedLoading).toBeFalse();
  });

  it('fetchForLocation handles error', () => {
    weatherStub.fetchWeather.and.returnValue(throwError(() => new Error('x')));
    (comp as unknown as { fetchForLocation(loc: ReturnType<typeof makeLocation>): void }).fetchForLocation(
      makeLocation()
    );
    expect(comp.error).toContain('Unable to fetch');
  });
});

describe('AppComponent with saved locations in storage', () => {
  let weatherStub: jasmine.SpyObj<WeatherService>;

  beforeEach(async () => {
    localStorage.clear();
    localStorage.setItem('saved-weather-locations-v1', JSON.stringify([makeLocation()]));
    weatherStub = jasmine.createSpyObj('WeatherService', [
      'resolveAndFetchWeather',
      'fetchWeather',
      'searchLocations',
      'localizeWeatherLabels',
    ]);
    weatherStub.resolveAndFetchWeather.and.returnValue(of(makeWeatherResult()));
    weatherStub.fetchWeather.and.returnValue(of(makeWeatherResult()));
    weatherStub.searchLocations.and.returnValue(of([]));
    weatherStub.localizeWeatherLabels.and.callFake((w: WeatherResult) => of(w));

    await TestBed.configureTestingModule({
      imports: [AppComponent],
      providers: [
        { provide: WeatherService, useValue: weatherStub },
        I18nService,
        provideAnimations(),
        provideHttpClient(),
      ],
    }).compileComponents();

    TestBed.createComponent(AppComponent);
  });

  it('refreshes saved location weather on init', () => {
    expect(weatherStub.fetchWeather).toHaveBeenCalled();
  });
});

describe('AppComponent suggestion stream', () => {
  let weatherStub: jasmine.SpyObj<WeatherService>;

  beforeEach(async () => {
    localStorage.clear();
    weatherStub = jasmine.createSpyObj('WeatherService', [
      'resolveAndFetchWeather',
      'fetchWeather',
      'searchLocations',
      'localizeWeatherLabels',
    ]);
    weatherStub.resolveAndFetchWeather.and.returnValue(of(makeWeatherResult()));
    weatherStub.fetchWeather.and.returnValue(of(makeWeatherResult()));
    weatherStub.searchLocations.and.returnValue(of([makeLocation()]));
    weatherStub.localizeWeatherLabels.and.callFake((w: WeatherResult) => of(w));

    await TestBed.configureTestingModule({
      imports: [AppComponent],
      providers: [
        { provide: WeatherService, useValue: weatherStub },
        I18nService,
        provideAnimations(),
        provideHttpClient(),
      ],
    }).compileComponents();
  });

  it('debounced city control updates suggestions', fakeAsync(() => {
    const fixture = TestBed.createComponent(AppComponent);
    const comp = fixture.componentInstance;
    comp.cityControl.setValue('Lon');
    tick(250);
    expect(comp.locationSuggestions.length).toBeGreaterThan(0);
  }));

  it('empty query clears via switchMap', fakeAsync(() => {
    const fixture = TestBed.createComponent(AppComponent);
    const comp = fixture.componentInstance;
    comp.cityControl.setValue('x');
    tick(250);
    comp.cityControl.setValue('');
    tick(250);
    expect(comp.locationSuggestions).toEqual([]);
  }));

  it('searchLocations error yields empty suggestions', fakeAsync(() => {
    weatherStub.searchLocations.and.returnValue(throwError(() => new Error('net')));
    const fixture = TestBed.createComponent(AppComponent);
    const comp = fixture.componentInstance;
    comp.cityControl.setValue('Err');
    tick(250);
    expect(comp.locationSuggestions).toEqual([]);
  }));
});
