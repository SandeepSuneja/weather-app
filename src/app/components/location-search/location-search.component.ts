import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { LocationOption, WeatherResult } from '../../weather.models';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-location-search',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, TranslatePipe],
  templateUrl: './location-search.component.html',
  styleUrls: ['./location-search.component.scss'],
})
export class LocationSearchComponent {
  @Input({ required: true }) cityControl!: FormControl<string>;
  @Input() loading = false;
  @Input() locationSuggestions: LocationOption[] = [];
  @Input() currentWeather: WeatherResult | null = null;
  @Input() currentLocationSaved = false;

  @Output() search = new EventEmitter<string>();
  @Output() selectSuggestion = new EventEmitter<LocationOption>();
  @Output() saveCurrent = new EventEmitter<void>();
}
