import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { WeatherService } from './weather.service';
import { I18nService } from './i18n.service';
import {
  airQualityJson,
  forecastJson,
  makeLocation,
  makeWeatherResult,
  minimalAirQualityJson,
  minimalForecastJson,
} from '../../test-utils/weather-fixtures';

describe('WeatherService', () => {
  let service: WeatherService;
  let http: HttpTestingController;
  let i18n: I18nService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [WeatherService, I18nService, provideHttpClient(), provideHttpClientTesting()],
    });
    service = TestBed.inject(WeatherService);
    http = TestBed.inject(HttpTestingController);
    i18n = TestBed.inject(I18nService);
    i18n.setLanguage('en');
  });

  afterEach(() => {
    http.verify();
  });

  function expectForecastPair() {
    const f = http.expectOne((r) => r.url.includes('api.open-meteo.com/v1/forecast'));
    f.flush(forecastJson());
    const a = http.expectOne((r) => r.url.includes('air-quality-api.open-meteo.com'));
    a.flush(airQualityJson());
  }

  it('searchLocations maps results', () => {
    service.searchLocations('Test').subscribe((rows) => {
      expect(rows.length).toBe(1);
      expect(rows[0].id).toBe(42);
      expect(rows[0].name).toBe('N');
    });
    const req = http.expectOne((r) => r.url.includes('geocoding-api.open-meteo.com/v1/search'));
    expect(req.request.urlWithParams).toContain('language=en');
    req.flush({
      results: [{ id: 42, name: 'N', country: 'C', latitude: 1, longitude: 2 }],
    });
  });

  it('searchLocations treats missing results as empty', () => {
    service.searchLocations('X').subscribe((rows) => expect(rows).toEqual([]));
    http.expectOne((r) => r.url.includes('/v1/search')).flush({});
  });

  it('resolveAndFetchWeather throws when no results', (done) => {
    service.resolveAndFetchWeather('zzz').subscribe({
      error: (e) => {
        expect(e.message).toContain('No matching location');
        done();
      },
    });
    const req = http.expectOne((r) => r.url.includes('/v1/search'));
    req.flush({ results: [] });
  });

  it('fetchWeather resolves by id then fetches forecast', () => {
    const loc = makeLocation({ id: 7, name: 'X', country: 'Y' });
    service.fetchWeather(loc).subscribe((w) => {
      expect(w.location.name).toBe('Localized');
      expect(w.current.temperature).toBe(22);
    });

    const getReq = http.expectOne((r) => r.url.includes('/v1/get'));
    expect(getReq.request.urlWithParams).toContain('id=7');
    getReq.flush({ id: 7, name: 'Localized', country: 'LC', latitude: 12.97, longitude: 77.59 });

    expectForecastPair();
  });

  it('fetchWeather keeps original location when get returns API error object', () => {
    const loc = makeLocation({ id: 7, name: 'Original', country: 'OC' });
    service.fetchWeather(loc).subscribe((w) => {
      expect(w.location.name).toBe('Original');
    });

    const getReq = http.expectOne((r) => r.url.includes('/v1/get'));
    getReq.flush({ error: true, reason: 'not found' });

    expectForecastPair();
  });

  it('fetchWeather without id uses forward geocode near coords', () => {
    const loc = makeLocation({ id: undefined, name: 'Old', latitude: 12.97, longitude: 77.59 });
    delete (loc as { id?: number }).id;
    service.fetchWeather(loc).subscribe((w) => {
      expect(w.location.name).toBe('Match');
    });

    const searchReq = http.expectOne((r) => r.url.includes('/v1/search'));
    expect(searchReq.request.urlWithParams).toContain('count=20');
    searchReq.flush({
      results: [{ id: 1, name: 'Match', country: 'IN', latitude: 12.975, longitude: 77.595 }],
    });

    expectForecastPair();
  });

  it('fetchWeather without id returns coordinate match when present', () => {
    const loc = makeLocation({ id: undefined, name: 'Old', latitude: 12.97, longitude: 77.59 });
    delete (loc as { id?: number }).id;
    service.fetchWeather(loc).subscribe((w) => {
      expect(w.location.name).toBe('Exact');
    });
    http.expectOne((r) => r.url.includes('/v1/search')).flush({
      results: [
        { id: 1, name: 'Far', country: 'X', latitude: 50, longitude: 50 },
        { id: 2, name: 'Exact', country: 'IN', latitude: 12.971, longitude: 77.591 },
      ],
    });
    expectForecastPair();
  });

  it('fetchWeather without id keeps original when search empty', () => {
    const loc = makeLocation({ id: undefined, name: 'Old', latitude: 12.97, longitude: 77.59 });
    delete (loc as { id?: number }).id;
    service.fetchWeather(loc).subscribe((w) => {
      expect(w.location.name).toBe('Old');
    });

    const searchReq = http.expectOne((r) => r.url.includes('/v1/search'));
    searchReq.flush({ results: [] });

    expectForecastPair();
  });

  it('fetchWeather without id keeps original when no result matches coordinates', () => {
    const loc = makeLocation({ id: undefined, name: 'Old', latitude: 12.97, longitude: 77.59 });
    delete (loc as { id?: number }).id;
    service.fetchWeather(loc).subscribe((w) => {
      expect(w.location.name).toBe('Old');
    });
    http.expectOne((r) => r.url.includes('/v1/search')).flush({
      results: [{ id: 1, name: 'FarOnly', country: 'X', latitude: 40, longitude: 40 }],
    });
    expectForecastPair();
  });

  it('localizeWeatherLabels updates display fields', (done) => {
    const result = makeWeatherResult();
    service.localizeWeatherLabels(result).subscribe((w) => {
      expect(w.locationName).toContain('NewName');
      done();
    });
    const getReq = http.expectOne((r) => r.url.includes('/v1/get'));
    getReq.flush({ id: 999001, name: 'NewName', country: 'NN', latitude: 12.97, longitude: 77.59 });
  });

  it('fetchWeather uses original location when get request errors', () => {
    const loc = makeLocation({ id: 5, name: 'Keep', country: 'K' });
    service.fetchWeather(loc).subscribe((w) => {
      expect(w.location.name).toBe('Keep');
    });

    const getReq = http.expectOne((r) => r.url.includes('/v1/get'));
    getReq.error(new ProgressEvent('network'));

    expectForecastPair();
  });

  it('resolveAndFetchWeather chains search, geocode get, and forecast', (done) => {
    service.resolveAndFetchWeather('Tok').subscribe((w) => {
      expect(w.location.name).toBe('Tokyo');
      expect(w.current.windDirectionDegrees).toBeNull();
      done();
    });
    http
      .expectOne((r) => r.url.includes('/v1/search'))
      .flush({ results: [{ id: 9, name: 'Tokyo', country: 'JP', latitude: 35, longitude: 139 }] });
    http
      .expectOne((r) => r.url.includes('/v1/get'))
      .flush({ id: 9, name: 'Tokyo', country: 'JP', latitude: 35, longitude: 139 });
    http.expectOne((r) => r.url.includes('forecast')).flush(minimalForecastJson());
    http.expectOne((r) => r.url.includes('air-quality')).flush(minimalAirQualityJson());
  });

  it('fetchWeather maps missing optional fields to null', (done) => {
    const loc = makeLocation({ id: 1 });
    service.fetchWeather(loc).subscribe((w) => {
      expect(w.hourly[0].precipitationProbability).toBeNull();
      expect(w.hourly[0].relativeHumidity).toBeNull();
      expect(w.daily[0].precipProbabilityMax).toBeNull();
      expect(w.pollution.usAqi).toBeNull();
      expect(w.current.pressureMsl).toBeNull();
      done();
    });
    http.expectOne((r) => r.url.includes('/v1/get')).flush({ id: 1, ...loc });
    http.expectOne((r) => r.url.includes('forecast')).flush(minimalForecastJson());
    http.expectOne((r) => r.url.includes('air-quality')).flush(minimalAirQualityJson());
  });

  it('getLocationById treats missing id in body as null', (done) => {
    const loc = makeLocation({ id: 2, name: 'N', country: 'C' });
    service.fetchWeather(loc).subscribe((w) => {
      expect(w.location.name).toBe('N');
      done();
    });
    http.expectOne((r) => r.url.includes('/v1/get')).flush({});
    expectForecastPair();
  });
});
