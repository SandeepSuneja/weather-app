import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output } from '@angular/core';
import { LocationOption, locationsMatch, WeatherResult } from '../../weather.models';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-saved-locations',
  standalone: true,
  imports: [CommonModule, TranslatePipe],
  templateUrl: './saved-locations.component.html',
  styleUrls: ['./saved-locations.component.scss'],
})
export class SavedLocationsComponent {
  /** When false, omit the section heading (e.g. parent supplies panel title). */
  @Input() showHeading = true;
  @Input() savedLoading = false;
  @Input() savedLocationWeather: WeatherResult[] = [];
  @Input() selectedLocation: LocationOption | null = null;
  @Output() openLocation = new EventEmitter<LocationOption>();
  @Output() removeLocation = new EventEmitter<LocationOption>();

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

  isSelected(location: LocationOption): boolean {
    if (!this.selectedLocation) {
      return false;
    }

    return locationsMatch(location, this.selectedLocation);
  }
}
