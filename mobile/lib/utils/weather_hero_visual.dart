import 'package:flutter/material.dart';

import '../models/weather_models.dart';
import '../theme/weatherly_palette.dart';

enum WeatherHeroScene { clear, mainlyClear, cloudy, rain, snow, storm }

WeatherHeroScene weatherHeroScene(int code) {
  if (code == 0) return WeatherHeroScene.clear;
  if (code == 1) return WeatherHeroScene.mainlyClear;
  if (code <= 3) return WeatherHeroScene.cloudy;
  if (code <= 67) return WeatherHeroScene.rain;
  if (code <= 77) return WeatherHeroScene.snow;
  return WeatherHeroScene.storm;
}

bool isNightAtLocation(WeatherResult data) {
  final now = DateTime.parse(data.current.time);
  if (data.daily.isNotEmpty) {
    final today = data.daily.first;
    final sunrise = today.sunrise;
    final sunset = today.sunset;
    if (sunrise != null && sunset != null) {
      final rise = DateTime.parse(sunrise);
      final set = DateTime.parse(sunset);
      return now.isBefore(rise) || now.isAfter(set);
    }
  }
  final hour = now.hour;
  return hour < 6 || hour >= 20;
}

class WeatherHeroVisual {
  const WeatherHeroVisual({
    required this.scene,
    required this.isNight,
    required this.gradient,
    required this.textureOpacity,
    required this.colorFilter,
    required this.icon,
    required this.iconColor,
  });

  final WeatherHeroScene scene;
  final bool isNight;
  final LinearGradient gradient;
  final double textureOpacity;
  final ColorFilter colorFilter;
  final IconData icon;
  final Color iconColor;
}

WeatherHeroVisual heroVisualFor(int code, {required bool isNight}) {
  final scene = weatherHeroScene(code);
  if (isNight) {
    return _nightVisual(scene);
  }
  return _dayVisual(scene);
}

WeatherHeroVisual _dayVisual(WeatherHeroScene scene) {
  return switch (scene) {
    WeatherHeroScene.clear => const WeatherHeroVisual(
        scene: WeatherHeroScene.clear,
        isNight: false,
        gradient: LinearGradient(
          begin: Alignment(-0.9, -1),
          end: Alignment(0.8, 1),
          colors: [Color(0xFFFFF8EB), Color(0xFFFFE4B5), Color(0xFFE9D5FF)],
          stops: [0, 0.42, 1],
        ),
        textureOpacity: 0.18,
        colorFilter: ColorFilter.mode(Color(0xFFFFCC80), BlendMode.softLight),
        icon: Icons.wb_sunny_rounded,
        iconColor: Color(0xFFF59E0B),
      ),
    WeatherHeroScene.mainlyClear => const WeatherHeroVisual(
        scene: WeatherHeroScene.mainlyClear,
        isNight: false,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDBEAFE), Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          stops: [0, 0.55, 1],
        ),
        textureOpacity: 0.16,
        colorFilter: ColorFilter.mode(Color(0xFF7DD3FC), BlendMode.softLight),
        icon: Icons.wb_twilight_rounded,
        iconColor: Color(0xFF6366F1),
      ),
    WeatherHeroScene.cloudy => const WeatherHeroVisual(
        scene: WeatherHeroScene.cloudy,
        isNight: false,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1F5F9), Color(0xFFCBD5E1), Color(0xFFE2E8F0)],
          stops: [0, 0.5, 1],
        ),
        textureOpacity: 0.14,
        colorFilter: ColorFilter.mode(Color(0xFF94A3B8), BlendMode.overlay),
        icon: Icons.cloud_rounded,
        iconColor: Color(0xFF64748B),
      ),
    WeatherHeroScene.rain => const WeatherHeroVisual(
        scene: WeatherHeroScene.rain,
        isNight: false,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF4338CA)],
          stops: [0, 0.45, 1],
        ),
        textureOpacity: 0.12,
        colorFilter: ColorFilter.mode(Color(0xFF334155), BlendMode.multiply),
        icon: Icons.water_drop_outlined,
        iconColor: Color(0xFFBAE6FD),
      ),
    WeatherHeroScene.snow => const WeatherHeroVisual(
        scene: WeatherHeroScene.snow,
        isNight: false,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0), Color(0xFFC7D2FE)],
          stops: [0, 0.5, 1],
        ),
        textureOpacity: 0.15,
        colorFilter: ColorFilter.mode(Color(0xFFBFDBFE), BlendMode.softLight),
        icon: Icons.ac_unit_rounded,
        iconColor: Color(0xFF6366F1),
      ),
    WeatherHeroScene.storm => const WeatherHeroVisual(
        scene: WeatherHeroScene.storm,
        isNight: false,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3730A3), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          stops: [0, 0.5, 1],
        ),
        textureOpacity: 0.1,
        colorFilter: ColorFilter.mode(Color(0xFF6366F1), BlendMode.overlay),
        icon: Icons.thunderstorm_rounded,
        iconColor: Color(0xFFFDE68A),
      ),
  };
}

WeatherHeroVisual _nightVisual(WeatherHeroScene scene) {
  return switch (scene) {
    WeatherHeroScene.clear || WeatherHeroScene.mainlyClear => const WeatherHeroVisual(
        scene: WeatherHeroScene.clear,
        isNight: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
          stops: [0, 0.45, 1],
        ),
        textureOpacity: 0.08,
        colorFilter: ColorFilter.mode(Color(0xFF4338CA), BlendMode.softLight),
        icon: Icons.nightlight_round,
        iconColor: Color(0xFFFEF3C7),
      ),
    WeatherHeroScene.cloudy => const WeatherHeroVisual(
        scene: WeatherHeroScene.cloudy,
        isNight: true,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF1E1B4B)],
        ),
        textureOpacity: 0.08,
        colorFilter: ColorFilter.mode(Color(0xFF475569), BlendMode.overlay),
        icon: Icons.nights_stay_rounded,
        iconColor: Color(0xFFCBD5E1),
      ),
    WeatherHeroScene.rain => const WeatherHeroVisual(
        scene: WeatherHeroScene.rain,
        isNight: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF312E81)],
        ),
        textureOpacity: 0.07,
        colorFilter: ColorFilter.mode(Color(0xFF334155), BlendMode.multiply),
        icon: Icons.water_drop_outlined,
        iconColor: Color(0xFF7DD3FC),
      ),
    WeatherHeroScene.snow => const WeatherHeroVisual(
        scene: WeatherHeroScene.snow,
        isNight: true,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF3730A3)],
        ),
        textureOpacity: 0.1,
        colorFilter: ColorFilter.mode(Color(0xFF94A3B8), BlendMode.softLight),
        icon: Icons.ac_unit_rounded,
        iconColor: Color(0xFFE0E7FF),
      ),
    WeatherHeroScene.storm => const WeatherHeroVisual(
        scene: WeatherHeroScene.storm,
        isNight: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF020617), Color(0xFF1E1B4B), Color(0xFF312E81)],
        ),
        textureOpacity: 0.06,
        colorFilter: ColorFilter.mode(Color(0xFF6366F1), BlendMode.overlay),
        icon: Icons.thunderstorm_rounded,
        iconColor: Color(0xFFFBBF24),
      ),
  };
}

WeatherHeroVisual defaultHeroVisual(BuildContext context, {bool isNight = false}) {
  final p = Theme.of(context).extension<WeatherlyPalette>() ?? WeatherlyPalette.light;
  return WeatherHeroVisual(
    scene: WeatherHeroScene.clear,
    isNight: isNight,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isNight
          ? const [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)]
          : [p.heroShellStart, p.heroShellMid, p.heroShellEnd],
      stops: const [0, 0.58, 1],
    ),
    textureOpacity: 0.14,
    colorFilter: ColorFilter.mode(
      isNight ? const Color(0xFF4338CA) : p.onAccent,
      BlendMode.softLight,
    ),
    icon: isNight ? Icons.nightlight_round : Icons.wb_cloudy_outlined,
    iconColor: isNight ? const Color(0xFFFEF3C7) : p.accent,
  );
}
