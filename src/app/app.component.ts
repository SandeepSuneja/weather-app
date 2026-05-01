import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormControl } from '@angular/forms';
import {
  animate,
  style,
  transition,
  trigger,
} from '@angular/animations';
import {
  catchError,
  debounceTime,
  distinctUntilChanged,
  finalize,
  forkJoin,
  of,
  switchMap,
  tap,
} from 'rxjs';
import { WeatherService } from './services/weather.service';
import { LocationOption, WeatherResult } from './weather.models';
import { LocationSearchComponent } from './components/location-search/location-search.component';
import { SavedLocationsComponent } from './components/saved-locations/saved-locations.component';
import { CurrentWeatherCardComponent } from './components/current-weather-card/current-weather-card.component';
import { HourlyForecastCardComponent } from './components/hourly-forecast-card/hourly-forecast-card.component';
import { DailyForecastCardComponent } from './components/daily-forecast-card/daily-forecast-card.component';
import { PollutionCardComponent } from './components/pollution-card/pollution-card.component';
import { I18nService, LanguageCode } from './services/i18n.service';
import { TranslatePipe } from './pipes/translate.pipe';

/** Local full-screen background: looping video or animated GIF. */
type BackgroundLayer = { type: 'video' | 'gif'; src: string };

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule,
    LocationSearchComponent,
    SavedLocationsComponent,
    CurrentWeatherCardComponent,
    HourlyForecastCardComponent,
    DailyForecastCardComponent,
    PollutionCardComponent,
    TranslatePipe,
  ],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
  animations: [
    trigger('fadeUp', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(16px)' }),
        animate(
          '350ms cubic-bezier(0.2, 0.9, 0.2, 1)',
          style({ opacity: 1, transform: 'translateY(0)' })
        ),
      ]),
    ]),
  ],
})
export class AppComponent {
  private static readonly STORAGE_KEY = 'saved-weather-locations-v1';

  readonly searchControl = new FormControl('Bengaluru', { nonNullable: true });
  readonly cityControl = new FormControl('', { nonNullable: true });

  loading = false;
  savedLoading = false;
  error = '';
  locationSuggestions: LocationOption[] = [];
  weather: WeatherResult | null = null;
  savedLocations: LocationOption[] = [];
  savedLocationWeather: WeatherResult[] = [];
  /** Local looping video or GIF; falls back to Unsplash when no asset applies. */
  bgLayer: BackgroundLayer | null = { type: 'video', src: 'assets/videos/sunny.mp4' };
  bgImageUrl = '';
  themeClass = 'theme-clear';
  languageNames: Record<LanguageCode, string> = {
    en: 'English',
    es: 'Español',
    fr: 'Français',
    de: 'Deutsch',
    pt: 'Português',
    hi: 'हिन्दी',
    zh: '中文',
    ar: 'العربية',
  };

  constructor(
    private readonly weatherService: WeatherService,
    public readonly i18n: I18nService
  ) {
    this.restoreSavedLocations();
    this.setupSuggestionStream();
    this.fetchForCity(this.searchControl.value);
    this.loadSavedLocationWeather();
  }

  changeLanguage(language: string): void {
    this.i18n.setLanguage(language as LanguageCode);
  }

  fetchForCity(city: string): void {
    if (!city.trim()) {
      return;
    }

    this.loading = true;
    this.error = '';
    this.weatherService
      .resolveAndFetchWeather(city.trim())
      .pipe(
        tap((result) => {
          this.weather = result;
          this.applyWeatherTheme(result.current.weatherCode, result.locationName);
          this.searchControl.setValue(city.trim(), { emitEvent: false });
          this.cityControl.setValue('', { emitEvent: false });
        }),
        catchError(() => {
          this.error = 'Unable to fetch weather right now. Try another city.';
          return of(null);
        }),
        finalize(() => {
          this.loading = false;
        })
      )
      .subscribe();
  }

  selectSuggestion(option: LocationOption): void {
    this.fetchForLocation(option);
    this.locationSuggestions = [];
  }

  addCurrentLocation(): void {
    if (!this.weather) {
      return;
    }

    const location = this.weather.location;
    if (this.isLocationSaved(location)) {
      return;
    }

    this.savedLocations = [...this.savedLocations, location];
    this.persistSavedLocations();
    this.loadSavedLocationWeather();
  }

  removeLocation(location: LocationOption): void {
    this.savedLocations = this.savedLocations.filter(
      (item) =>
        !(
          item.name === location.name &&
          item.country === location.country &&
          item.latitude === location.latitude &&
          item.longitude === location.longitude
        )
    );
    this.savedLocationWeather = this.savedLocationWeather.filter(
      (item) => !this.isSameLocation(item.location, location)
    );
    this.persistSavedLocations();
  }

  openSavedLocation(location: LocationOption): void {
    this.fetchForLocation(location);
  }

  isCurrentLocationSaved(): boolean {
    return !!this.weather && this.isLocationSaved(this.weather.location);
  }

  private weatherLabel(code: number): string {
    if (code === 0) {
      return 'clear';
    }
    if (code <= 3) {
      return 'cloudy';
    }
    if (code <= 67) {
      return 'rain';
    }
    if (code <= 77) {
      return 'snow';
    }
    return 'storm';
  }

  private setupSuggestionStream(): void {
    this.cityControl.valueChanges
      .pipe(
        debounceTime(250),
        distinctUntilChanged(),
        switchMap((query) => {
          if (!query.trim()) {
            return of([]);
          }
          return this.weatherService.searchLocations(query.trim()).pipe(catchError(() => of([])));
        })
      )
      .subscribe((suggestions) => {
        this.locationSuggestions = suggestions;
      });
  }

  private fetchForLocation(location: LocationOption): void {
    this.loading = true;
    this.error = '';
    this.weatherService
      .fetchWeather(location)
      .pipe(
        tap((result) => {
          this.weather = result;
          this.applyWeatherTheme(result.current.weatherCode, result.locationName);
          this.searchControl.setValue(location.name, { emitEvent: false });
          this.cityControl.setValue('', { emitEvent: false });
          this.locationSuggestions = [];
        }),
        catchError(() => {
          this.error = 'Unable to fetch weather right now. Try another city.';
          return of(null);
        }),
        finalize(() => {
          this.loading = false;
        })
      )
      .subscribe();
  }

  private loadSavedLocationWeather(): void {
    if (!this.savedLocations.length) {
      this.savedLocationWeather = [];
      return;
    }

    this.savedLoading = true;
    this.error = '';
    forkJoin(this.savedLocations.map((location) => this.weatherService.fetchWeather(location)))
      .pipe(
        tap((weatherList) => {
          this.savedLocationWeather = weatherList;
        }),
        catchError(() => {
          this.error = 'Unable to refresh saved locations.';
          return of([]);
        }),
        finalize(() => {
          this.savedLoading = false;
        })
      )
      .subscribe();
  }

  private isLocationSaved(location: LocationOption): boolean {
    return this.savedLocations.some((item) => this.isSameLocation(item, location));
  }

  private isSameLocation(a: LocationOption, b: LocationOption): boolean {
    return (
      a.name === b.name &&
      a.country === b.country &&
      a.latitude === b.latitude &&
      a.longitude === b.longitude
    );
  }

  private persistSavedLocations(): void {
    localStorage.setItem(AppComponent.STORAGE_KEY, JSON.stringify(this.savedLocations));
  }

  private restoreSavedLocations(): void {
    const raw = localStorage.getItem(AppComponent.STORAGE_KEY);
    if (!raw) {
      return;
    }

    try {
      const parsed = JSON.parse(raw) as LocationOption[];
      if (Array.isArray(parsed)) {
        this.savedLocations = parsed.filter(
          (item) =>
            typeof item?.name === 'string' &&
            typeof item?.country === 'string' &&
            typeof item?.latitude === 'number' &&
            typeof item?.longitude === 'number'
        );
      }
    } catch {
      this.savedLocations = [];
    }
  }

  private applyWeatherTheme(weatherCode: number, locationName: string): void {
    const weatherTheme = this.weatherLabel(weatherCode);
    this.themeClass = `theme-${weatherTheme}`;
    const layer = this.localBackgroundForCode(weatherCode);
    if (layer) {
      this.bgLayer = layer;
      this.bgImageUrl = '';
      return;
    }
    this.bgLayer = null;
    this.bgImageUrl = this.getBackgroundUrl(weatherTheme, locationName);
  }

  /**
   * WMO weather codes (Open-Meteo). Assets under `assets/videos/`.
   * 0 clear → sunny; 1 mainly clear → rainbow; 2–3 cloudy → GIF;
   * 4–67 precipitation / drizzle / rain → rainy; 68–77 snow → snowy; 78+ thunder/hail → thunderstorm GIF.
   */
  private localBackgroundForCode(code: number): BackgroundLayer | null {
    if (!Number.isFinite(code)) {
      return null;
    }
    if (code === 0) {
      return { type: 'video', src: 'assets/videos/sunny.mp4' };
    }
    if (code === 1) {
      return { type: 'video', src: 'assets/videos/rainbow.mp4' };
    }
    if (code >= 2 && code <= 3) {
      return { type: 'gif', src: 'assets/videos/cloudy.gif' };
    }
    if (code >= 4 && code <= 67) {
      return { type: 'video', src: 'assets/videos/rainy.mp4' };
    }
    if (code >= 68 && code <= 77) {
      return { type: 'video', src: 'assets/videos/snowy.mp4' };
    }
    if (code >= 78) {
      return { type: 'gif', src: 'assets/videos/thunderstorm.gif' };
    }
    return null;
  }

  private getBackgroundUrl(condition: string, locationName: string): string {
    const locationQuery = locationName.split(',')[0]?.trim() || locationName;
    return `https://source.unsplash.com/1800x1200/?${encodeURIComponent(
      locationQuery
    )},${encodeURIComponent(condition)},weather`;
  }
}
