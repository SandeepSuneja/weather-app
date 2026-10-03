# Weatherly Mobile (Flutter / Android)

Android port of the **Weatherly** weather dashboard in the repo root (`../`). Uses the same **[Open-Meteo](https://open-meteo.com/)** APIs (forecast, geocoding, air quality). **No API keys required.**

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel; this project targets Dart 3.11+)
- Android SDK / device or emulator with Google APIs

Check your setup:

```bash
flutter doctor
```

## Run on Android

From this folder (`mobile/`):

```bash
flutter pub get
flutter run
```

With a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

Release APK (local testing):

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Project layout

| Path | Purpose |
|------|---------|
| `lib/models/` | Data types aligned with the Angular `weather.models.ts` |
| `lib/services/weather_service.dart` | Open-Meteo HTTP client |
| `lib/services/i18n.dart` | EN / HI / JA UI strings |
| `lib/services/saved_locations_repository.dart` | `shared_preferences` (same storage key as web) |
| `lib/screens/home_screen.dart` | Main dashboard |
| `lib/widgets/weather_cards.dart` | Current, hourly, daily cards |

## Parity with the web app

Implemented in this scaffold:

- City search with geocoding suggestions
- Current weather, 12-hour and 5-day forecasts
- Air quality (when returned by API)
- Saved locations drawer
- Language switcher (English, Hindi, Japanese)
- Pull-to-refresh

Not yet ported (good next steps):

- Animated video/GIF backgrounds per WMO code
- Hourly temperature chart and richer pollution card styling
- Full visual parity with Angular SCSS / layout

## Web vs mobile

| | Web (`npm start`) | Mobile (`flutter run`) |
|--|-------------------|-------------------------|
| Root | Repository root | `mobile/` |
| Storage | Browser `localStorage` | `shared_preferences` |
| Saved key | `saved-weather-locations-v1` | Same key name |
