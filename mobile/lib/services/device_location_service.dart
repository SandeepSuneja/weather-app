import 'dart:async';



import 'package:flutter/foundation.dart';

import 'package:geolocator/geolocator.dart';



class DeviceCoordinates {

  const DeviceCoordinates({required this.latitude, required this.longitude});



  final double latitude;

  final double longitude;

}



class DeviceLocationService {

  static const _attempts = [

    (LocationAccuracy.high, Duration(seconds: 25)),

    (LocationAccuracy.medium, Duration(seconds: 20)),

    (LocationAccuracy.low, Duration(seconds: 15)),

  ];



  static const _lastKnownMaxAge = Duration(minutes: 45);



  Future<DeviceCoordinates> getCurrentPosition() async {

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {

      throw LocationServicesDisabledException();

    }



    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission = await Geolocator.requestPermission();

    }

    if (permission == LocationPermission.denied) {

      throw LocationPermissionDeniedException();

    }

    if (permission == LocationPermission.deniedForever) {

      throw LocationPermissionDeniedForeverException();

    }



    Position? position;

    for (final (accuracy, timeLimit) in _attempts) {

      try {

        position = await Geolocator.getCurrentPosition(

          locationSettings: LocationSettings(

            accuracy: accuracy,

            timeLimit: timeLimit,

          ),

        );

        debugPrint(

          '[Weatherly] GPS fix accuracy=$accuracy '

          'lat=${position.latitude} lon=${position.longitude}',

        );

        break;

      } on TimeoutException {

        debugPrint('[Weatherly] GPS timeout at accuracy=$accuracy');

      } catch (e) {

        debugPrint('[Weatherly] GPS error at accuracy=$accuracy: $e');

      }

    }



    position ??= await _freshLastKnownPosition();



    if (position == null) {

      throw LocationUnavailableException();

    }



    return DeviceCoordinates(

      latitude: position.latitude,

      longitude: position.longitude,

    );

  }



  Future<Position?> _freshLastKnownPosition() async {

    final last = await Geolocator.getLastKnownPosition();

    if (last == null) {

      return null;

    }

    final age = DateTime.now().difference(last.timestamp);

    if (age > _lastKnownMaxAge) {

      debugPrint(

        '[Weatherly] Ignoring stale last-known GPS (${age.inMinutes} min old)',

      );

      return null;

    }

    debugPrint(

      '[Weatherly] Using last-known GPS (${age.inMinutes} min old) '

      'lat=${last.latitude} lon=${last.longitude}',

    );

    return last;

  }

}



class LocationServicesDisabledException implements Exception {}



class LocationPermissionDeniedException implements Exception {}



class LocationPermissionDeniedForeverException implements Exception {}



class LocationUnavailableException implements Exception {}

