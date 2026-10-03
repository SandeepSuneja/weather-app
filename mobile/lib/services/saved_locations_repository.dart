import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_models.dart';

class SavedLocationsRepository {
  SavedLocationsRepository({SharedPreferences? prefs}) : _prefs = prefs;

  static const storageKey = 'saved-weather-locations-v1';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<LocationOption>> load() async {
    final prefs = await _storage;
    final raw = prefs.getString(storageKey);
    if (raw == null) {
      return [];
    }
    try {
      final parsed = jsonDecode(raw) as List;
      return parsed
          .whereType<Map<String, dynamic>>()
          .where(
            (item) =>
                item['name'] is String &&
                item['country'] is String &&
                item['latitude'] is num &&
                item['longitude'] is num,
          )
          .map(LocationOption.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<LocationOption> locations) async {
    final prefs = await _storage;
    final encoded = jsonEncode(locations.map((l) => l.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }
}
