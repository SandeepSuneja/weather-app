import 'package:shared_preferences/shared_preferences.dart';

import 'device_location_service.dart';

/// Persists the last successful GPS fix so a brief timeout does not fall back to
/// an unrelated default city.
class LastDeviceLocationRepository {
  LastDeviceLocationRepository({SharedPreferences? prefs}) : _prefs = prefs;

  static const _keyLat = 'last-device-latitude';
  static const _keyLon = 'last-device-longitude';
  static const _keyMs = 'last-device-timestamp-ms';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> save(DeviceCoordinates coords) async {
    final prefs = await _storage;
    await prefs.setDouble(_keyLat, coords.latitude);
    await prefs.setDouble(_keyLon, coords.longitude);
    await prefs.setInt(_keyMs, DateTime.now().millisecondsSinceEpoch);
  }

  Future<DeviceCoordinates?> loadRecent({
    Duration maxAge = const Duration(hours: 48),
  }) async {
    final prefs = await _storage;
    final lat = prefs.getDouble(_keyLat);
    final lon = prefs.getDouble(_keyLon);
    final ms = prefs.getInt(_keyMs);
    if (lat == null || lon == null || ms == null) {
      return null;
    }
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ms),
    );
    if (age > maxAge) {
      return null;
    }
    return DeviceCoordinates(latitude: lat, longitude: lon);
  }
}
