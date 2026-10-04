/// English UI copy (single locale).
abstract final class AppStrings {
  static const appTitle = 'Weatherly';
  static const searchPlaceholder = 'Search city...';
  static const searchLoading = 'Loading...';
  static const saveLocation = 'Save Location';
  static const saved = 'Saved';
  static const savedTitle = 'Saved Locations';
  static const savedRefreshing = 'Refreshing saved locations...';
  static const savedRemove = 'Remove';
  static const savedEmpty = 'No saved places yet.';
  static const addedToCities = 'Added to Cities';
  static const hourlyTitle = 'Next 12 Hours';
  static const dailyTitle = '5-Day Forecast';
  static const dailyPrecip = 'Rain chance';
  static const dailyUv = 'UV max';
  static const dailyWind = 'Wind max';
  static const feelsLike = 'Feels like';
  static const humidity = 'Humidity';
  static const wind = 'Wind';
  static const pressure = 'Pressure';
  static const cloudCover = 'Cloud cover';
  static const uvIndex = 'UV index';
  static const pollutionTitle = 'Air Quality';
  static const aqiUnavailable = 'Unavailable';
  static const weatherClear = 'Clear';
  static const weatherCloudy = 'Cloudy';
  static const weatherRain = 'Rain';
  static const weatherSnow = 'Snow';
  static const weatherStorm = 'Storm';
  static const errorFetch = 'Unable to fetch weather right now. Try another city.';
  static const errorNotFound = 'No matching location found.';
  static const errorLocationPermission =
      'Location permission is off. Enable it in settings or pick a city.';
  static const errorLocationDisabled = 'Location services are disabled on this device.';
  static const settingsTitle = 'Settings';
  static const settingsUseDeviceLocation = 'Use my current location';
  static const useCurrentLocation = 'Current location';
  static const fetchingCurrentLocation = 'Getting your location…';
  static const settingsAppearance = 'Appearance';
  static const settingsThemeLight = 'Light';
  static const settingsThemeDark = 'Dark';
  static const settingsThemeSystem = 'System default';
  static const locationCurrent = 'Current location';
  static const locationNearby = 'Nearby';
  static const citiesSearchPlaceholder = 'Search for a city or airport';
  static const citiesSavedLocations = 'Saved locations';
  static const citiesEditList = 'Edit list';
  static const citiesDoneEditing = 'Done';
  static const citiesAddCity = 'Add city';

  static const gpsPlaceholderNames = {locationCurrent};
  static const gpsPlaceholderCountries = {locationNearby};

  static bool isGpsPlaceholderLocation(String name, String country) {
    return gpsPlaceholderNames.contains(name) && gpsPlaceholderCountries.contains(country);
  }

  static String weatherLabelForKey(String key) {
    return switch (key) {
      'weather.clear' => weatherClear,
      'weather.cloudy' => weatherCloudy,
      'weather.rain' => weatherRain,
      'weather.snow' => weatherSnow,
      'weather.storm' => weatherStorm,
      _ => weatherClear,
    };
  }
}
