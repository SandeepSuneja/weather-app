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
  static const removedFromCities = 'Removed from Cities';
  static const hourlyTitle = 'Next 12 Hours';
  static const dailyTitle = '7-Day Forecast';
  static const chartsTitle = 'Charts';
  static const chartsNeedWeather =
      'Open the Dashboard and load a location to see charts here.';
  static const chartTemperature = 'Temperature';
  static const chartTemperatureSubtitle = 'Actual and feels-like (°C)';
  static const chartPrecipitation = 'Rain chance';
  static const chartPrecipitationSubtitle = 'Hourly precipitation probability';
  static const chartWind = 'Wind speed';
  static const chartWindSubtitle = 'km/h at 10 m';
  static const chartHumidity = 'Humidity';
  static const chartHumiditySubtitle = 'Relative humidity %';
  static const chartAirQuality = 'Air quality index';
  static const chartAirQualitySubtitle = 'US AQI (hourly)';
  static const chartDailyTemperature = 'Daily temperature';
  static const chartDailyTemperatureSubtitle = 'Low–high range (°C)';
  static const chartDailyPrecip = 'Daily rain chance';
  static const chartDailyWind = 'Daily max wind';
  static const chartTouchHint = 'Press or drag on a chart to see values';
  static const chartLegendActual = 'Actual temp';
  static const chartLegendFeelsLike = 'Feels like';
  static const chartPressure = 'Pressure';
  static const chartPressureSubtitle = 'Mean sea level (hPa)';
  static const chartUv = 'UV index';
  static const chartUvSubtitle = 'Hourly UV intensity';
  static const chartCloudCover = 'Cloud cover';
  static const chartCloudCoverSubtitle = 'Sky coverage %';
  static const chartParticulates = 'Fine particles';
  static const chartParticulatesSubtitle = 'PM2.5 and PM10 (µg/m³)';
  static const chartLegendPm25 = 'PM2.5';
  static const chartLegendPm10 = 'PM10';
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
  static const pollutionAqiLabel = 'US AQI';
  static const pollutionPm25 = 'PM2.5';
  static const pollutionPm10 = 'PM10';
  static const pollutionNo2 = 'NO₂';
  static const pollutionO3 = 'O₃';
  static const pollutionCo = 'CO';
  static const pollutionUnitUg = 'µg/m³';
  static const pollutionPartialHint = 'Pollutant readings for this area (AQI index unavailable).';
  static const aqiUnavailable = 'Air quality data is not available for this location right now.';
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

  static const assistantTitle = 'Assistant';
  static const assistantNeedWeather =
      'Load a location on the Dashboard first—I answer using your current forecast.';
  static const assistantEmptyPrompt = 'Ask something about the weather for this location.';
  static const assistantOffTopic =
      'I can only help with weather for your loaded location—try a question about rain, what to wear, air quality, or the week ahead.';
  static const assistantWelcome =
      'Ask about rain, what to wear, outdoor plans, air quality, or the week ahead. Tap a suggestion or type your question.';
  static const assistantInputHint = 'Ask about the weather…';
  static const assistantSend = 'Send';
  static const assistantClearChat = 'Clear chat';
  static const assistantChipUmbrella = 'Do I need an umbrella?';
  static const assistantChipRun = 'Good time for a run?';
  static const assistantChipWear = 'What should I wear?';
  static const assistantChipAir = 'How is air quality?';
  static const assistantChipWeekend = 'Week ahead';
  static const assistantChipSummary = 'Weather summary';
  static const assistantUmbrellaYesNow = 'Yes—keep an umbrella handy. It is already wet or raining';
  static const assistantUmbrellaNo =
      'You probably do not need an umbrella—the next 12 hours look mostly dry.';
  static const assistantNoTomorrow = 'Tomorrow’s forecast is not available yet for this location.';
  static const assistantNoUv = 'UV data is not available for this spot right now.';

  static String assistantUmbrellaLater(int peakProb, String when) =>
      'Yes—rain is likely later (about $peakProb% around $when). A compact umbrella is a good idea.';

  static String assistantUmbrellaMaybe(int peakProb) =>
      'Maybe—a light rain chance ($peakProb%) shows up in the hourly forecast. A small umbrella is optional.';

  static String assistantRunGood(int temp, int humidity) =>
      'Looks reasonable for outdoor exercise at about $temp° with $humidity% humidity.';

  static String assistantRunCaution(String issues) =>
      'Use caution: $issues. Consider a shorter session or moving indoors.';

  static String assistantWearIntro(int feels) =>
      'With a feels-like temperature around $feels°, consider';

  static String assistantFooterLocation(String name) => 'Based on $name.';

  static String assistantFooterUpdated(String name, String time) =>
      'Based on $name · updated $time';

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
