import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';
import 'screens/home_screen.dart';
import 'services/theme_preferences.dart';
import 'theme/weatherly_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ThemePreferences.instance.load();
  runApp(const WeatherlyApp());
}

class WeatherlyApp extends StatelessWidget {
  const WeatherlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemePreferences.instance,
      builder: (context, _) {
        return MaterialApp(
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: WeatherlyTheme.lightTheme(),
          darkTheme: WeatherlyTheme.darkTheme(),
          themeMode: ThemePreferences.instance.mode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
