import 'dart:async';

import 'package:flutter/material.dart';

import '../models/weather_models.dart';
import '../services/device_location_service.dart';
import '../l10n/app_strings.dart';
import '../services/last_device_location_repository.dart';
import '../services/theme_preferences.dart';
import '../services/saved_locations_repository.dart';
import '../services/weather_service.dart';
import '../theme/weatherly_palette.dart';
import '../theme/weatherly_responsive.dart';
import '../utils/weather_debug_log.dart';
import '../widgets/home_premium/cities_screen.dart';
import '../widgets/home_premium/dashboard_sections.dart';
import '../widgets/home_premium/weatherly_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _weatherService = WeatherService();
  final _savedRepo = SavedLocationsRepository();
  final _deviceLocation = DeviceLocationService();
  final _lastDeviceLocation = LastDeviceLocationRepository();
  final _searchController = TextEditingController();
  final _cityController = TextEditingController();
  final _citiesSearchFocus = FocusNode();

  bool _loading = false;
  bool _savedLoading = false;
  String _error = '';
  WeatherResult? _weather;
  List<LocationOption> _suggestions = [];
  List<LocationOption> _savedLocations = [];
  List<WeatherResult> _savedWeather = [];
  Timer? _debounce;
  WeatherlyNavItem _nav = WeatherlyNavItem.dashboard;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _savedLocations = await _savedRepo.load();
    if (mounted) setState(() {});
    await _fetchForDeviceLocation(fallbackToSaved: false);
    unawaited(_refreshSavedWeather());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _cityController.dispose();
    _citiesSearchFocus.dispose();
    super.dispose();
  }

  bool get _currentSaved =>
      _weather != null &&
      _savedLocations.any((l) => locationsMatch(l, _weather!.location));

  void _applyDashboardWeather(WeatherResult result) {
    logDashboardWeather(result);
    setState(() {
      _weather = result;
      _searchController.text = result.location.name;
      _cityController.clear();
      _suggestions = [];
    });
  }

  Future<void> _fetchForDeviceLocation({bool fallbackToSaved = false}) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final coords = await _resolveDeviceCoordinates();
      final result = await _weatherService.fetchWeatherForCoordinates(
        coords.latitude,
        coords.longitude,
      );
      if (!mounted) return;
      await _lastDeviceLocation.save(coords);
      _applyDashboardWeather(result);
    } on LocationServicesDisabledException {
      if (!mounted) return;
      await _handleLocationFallback(
        fallbackToSaved: fallbackToSaved,
        message: AppStrings.errorLocationDisabled,
      );
    } on LocationPermissionDeniedException {
      if (!mounted) return;
      await _handleLocationFallback(
        fallbackToSaved: fallbackToSaved,
        message: AppStrings.errorLocationPermission,
      );
    } on LocationPermissionDeniedForeverException {
      if (!mounted) return;
      await _handleLocationFallback(
        fallbackToSaved: fallbackToSaved,
        message: AppStrings.errorLocationPermission,
      );
    } on LocationUnavailableException {
      if (!mounted) return;
      await _handleLocationFallback(
        fallbackToSaved: fallbackToSaved,
        message: AppStrings.errorFetch,
      );
    } on WeatherFetchException {
      if (!mounted) return;
      await _handleLocationFallback(
        fallbackToSaved: fallbackToSaved,
        message: AppStrings.errorFetch,
      );
    } catch (e, st) {
      debugPrint('[Weatherly] device location fetch failed: $e\n$st');
      if (!mounted) return;
      await _handleLocationFallback(
        fallbackToSaved: fallbackToSaved,
        message: AppStrings.errorFetch,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<DeviceCoordinates> _resolveDeviceCoordinates() async {
    try {
      return await _deviceLocation.getCurrentPosition();
    } on LocationServicesDisabledException {
      rethrow;
    } on LocationPermissionDeniedException {
      rethrow;
    } on LocationPermissionDeniedForeverException {
      rethrow;
    } catch (e) {
      debugPrint('[Weatherly] Live GPS unavailable: $e');
      final cached = await _lastDeviceLocation.loadRecent();
      if (cached != null) {
        debugPrint(
          '[Weatherly] Using cached device location '
          'lat=${cached.latitude} lon=${cached.longitude}',
        );
        return cached;
      }
      throw LocationUnavailableException();
    }
  }

  Future<void> _handleLocationFallback({
    required bool fallbackToSaved,
    required String message,
  }) async {
    if (fallbackToSaved && _savedLocations.isNotEmpty) {
      await _fetchForLocation(_savedLocations.first, manageLoading: false);
      _showSnack(message);
      return;
    }
    if (mounted) setState(() => _error = message);
  }

  Future<void> _submitCitySearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }
    if (_suggestions.isNotEmpty) {
      await _onPickCitySuggestion(_suggestions.first);
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final result = await _weatherService.resolveAndFetchWeather(trimmed);
      if (!_savedLocations.any((l) => locationsMatch(l, result.location))) {
        _savedLocations = [..._savedLocations, result.location];
        await _savedRepo.save(_savedLocations);
      }
      await _refreshSavedWeather();
      if (!mounted) {
        return;
      }
      await _openCityFromManager(result.location);
    } on LocationNotFoundException {
      if (mounted) {
        _showSnack(AppStrings.errorNotFound);
      }
    } catch (_) {
      if (mounted) {
        _showSnack(AppStrings.errorFetch);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _fetchForLocation(
    LocationOption location, {
    bool manageLoading = true,
  }) async {
    if (manageLoading) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }
    try {
      final result = await _weatherService.fetchWeather(location);
      if (!mounted) return;
      _applyDashboardWeather(result);
    } catch (_) {
      if (mounted) setState(() => _error = AppStrings.errorFetch);
    } finally {
      if (manageLoading && mounted) setState(() => _loading = false);
    }
  }

  void _onCityChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (query.trim().isEmpty) {
        if (mounted) setState(() => _suggestions = []);
        return;
      }
      try {
        final list = await _weatherService.searchLocations(query.trim());
        if (mounted) setState(() => _suggestions = list);
      } catch (_) {
        if (mounted) setState(() => _suggestions = []);
      }
    });
  }

  Future<void> _addCurrentLocation() async {
    final w = _weather;
    if (w == null || _currentSaved) return;
    _savedLocations = [..._savedLocations, w.location];
    await _savedRepo.save(_savedLocations);
    if (mounted) setState(() {});
    await _refreshSavedWeather();
    _showSnack(AppStrings.addedToCities);
  }

  Future<void> _removeLocation(LocationOption location) async {
    _savedLocations =
        _savedLocations.where((l) => !locationsMatch(l, location)).toList();
    _savedWeather =
        _savedWeather.where((w) => !locationsMatch(w.location, location)).toList();
    await _savedRepo.save(_savedLocations);
    if (mounted) setState(() {});
  }

  Future<void> _reorderSavedLocations(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updated = [..._savedLocations];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    _savedLocations = updated;
    await _savedRepo.save(_savedLocations);
    if (mounted) setState(() {});
  }

  Future<void> _openCityFromManager(LocationOption location) async {
    setState(() {
      _nav = WeatherlyNavItem.dashboard;
      _suggestions = [];
      _cityController.clear();
    });
    await _fetchForLocation(location);
  }

  Future<void> _onPickCitySuggestion(LocationOption location) async {
    if (!_savedLocations.any((l) => locationsMatch(l, location))) {
      _savedLocations = [..._savedLocations, location];
      await _savedRepo.save(_savedLocations);
    }
    _cityController.clear();
    if (mounted) {
      setState(() => _suggestions = []);
    }
    await _refreshSavedWeather();
    await _openCityFromManager(location);
  }

  Future<void> _refreshSavedWeather() async {
    if (_savedLocations.isEmpty) {
      if (mounted) setState(() => _savedWeather = []);
      return;
    }
    setState(() => _savedLoading = true);
    try {
      final list = await Future.wait(
        _savedLocations.map(_weatherService.fetchWeather),
      );
      if (mounted) setState(() => _savedWeather = list);
    } catch (_) {
      if (mounted) setState(() => _error = AppStrings.errorFetch);
    } finally {
      if (mounted) setState(() => _savedLoading = false);
    }
  }

  void _onNavSelect(WeatherlyNavItem item) {
    setState(() => _nav = item);
    switch (item) {
      case WeatherlyNavItem.dashboard:
        break;
      case WeatherlyNavItem.charts:
        _showSnack('Charts coming soon');
        break;
      case WeatherlyNavItem.assistant:
        _showSnack('Assistant coming soon');
        break;
      case WeatherlyNavItem.cities:
        unawaited(_refreshSavedWeather());
        break;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSettingsSheet() {
    final themePrefs = ThemePreferences.instance;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListenableBuilder(
            listenable: themePrefs,
            builder: (context, _) {
              final mode = themePrefs.mode;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppStrings.settingsTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.my_location_outlined),
                    title: const Text(AppStrings.settingsUseDeviceLocation),
                    onTap: () {
                      Navigator.pop(context);
                      unawaited(_fetchForDeviceLocation(fallbackToSaved: false));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.settingsAppearance,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text(AppStrings.settingsThemeLight),
                    value: ThemeMode.light,
                    groupValue: mode,
                    onChanged: (v) => themePrefs.setMode(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text(AppStrings.settingsThemeDark),
                    value: ThemeMode.dark,
                    groupValue: mode,
                    onChanged: (v) => themePrefs.setMode(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text(AppStrings.settingsThemeSystem),
                    value: ThemeMode.system,
                    groupValue: mode,
                    onChanged: (v) => themePrefs.setMode(v!),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    if (_weather != null) {
      await _fetchForLocation(_weather!.location);
    } else {
      await _fetchForDeviceLocation(fallbackToSaved: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = _weather;
    final palette = context.palette;

    final isCities = _nav == WeatherlyNavItem.cities;

    return Scaffold(
      floatingActionButton: isCities
          ? FloatingActionButton(
              onPressed: () {
                _citiesSearchFocus.requestFocus();
              },
              tooltip: AppStrings.citiesAddCity,
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.weatherly.radiusS)),
              child: Icon(Icons.add, color: palette.onAccent),
            )
          : null,
      body: isCities
          ? CitiesScreen(
              searchController: _cityController,
              searchFocusNode: _citiesSearchFocus,
              savedLocations: _savedLocations,
              savedWeather: _savedWeather,
              savedLoading: _savedLoading,
              activeLocation: weather?.location,
              suggestions: _suggestions,
              onSearchChanged: _onCityChanged,
              onSelectSuggestion: _onPickCitySuggestion,
              onSelectSaved: _openCityFromManager,
              onRemoveSaved: _removeLocation,
              onReorderSaved: _reorderSavedLocations,
              onExploreMap: () => _showSnack(AppStrings.citiesMapComingSoon),
              onSearchSubmit: _submitCitySearch,
            )
          : Container(
              decoration: BoxDecoration(gradient: palette.pageBackground),
              child: Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: WeatherlyTopBar(
                      title: AppStrings.appTitle,
                      onSettings: _showSettingsSheet,
                      onSaveLocation: weather != null ? _addCurrentLocation : null,
                      locationSaved: _currentSaved,
                      saveTooltip:
                          _currentSaved ? AppStrings.saved : AppStrings.saveLocation,
                      settingsTooltip: AppStrings.settingsTitle,
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: Builder(
                        builder: (context) {
                          final lay = context.weatherly;
                          return ListView(
                            padding: EdgeInsets.fromLTRB(
                              lay.pagePaddingH,
                              lay.pagePaddingV,
                              lay.pagePaddingH,
                              lay.scrollBottomInset,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              HeroWeatherSection(data: weather, loading: _loading),
                              if (_error.isNotEmpty) ...[
                                SizedBox(height: lay.gapM),
                                Text(_error, style: const TextStyle(color: Colors.red)),
                              ],
                              if (weather != null) ...[
                                SizedBox(height: lay.sectionGap),
                                AiInsightCard(data: weather),
                                SizedBox(height: lay.gapM),
                                MiniStatsGrid(data: weather),
                                SizedBox(height: lay.sectionGap),
                              HourlyForecastSection(hourly: weather.hourly),
                              SizedBox(height: lay.sectionGap),
                              DailyForecastSection(daily: weather.daily),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: WeatherlyBottomNav(active: _nav, onSelect: _onNavSelect),
    );
  }
}
