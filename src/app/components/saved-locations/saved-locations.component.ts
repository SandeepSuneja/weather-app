import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output } from '@angular/core';
import { LocationOption, WeatherResult } from '../../weather.models';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-saved-locations',
  standalone: true,
  imports: [CommonModule, TranslatePipe],
  templateUrl: './saved-locations.component.html',
  styleUrls: ['./saved-locations.component.scss'],
})
export class SavedLocationsComponent {
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

    return (
      location.name === this.selectedLocation.name &&
      location.country === this.selectedLocation.country &&
      location.latitude === this.selectedLocation.latitude &&
      location.longitude === this.selectedLocation.longitude
    );
  }
}
