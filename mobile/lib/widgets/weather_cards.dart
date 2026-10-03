import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../models/weather_models.dart';
import '../utils/weather_utils.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key, required this.data});

  final WeatherResult data;

  @override
  Widget build(BuildContext context) {
    final c = data.current;
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.locationName, style: theme.textTheme.titleLarge),
            Row(
              children: [
                Text(weatherEmoji(c.weatherCode), style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c.temperature.round()}°', style: theme.textTheme.headlineMedium),
                    Text(weatherLabel(c.weatherCode)),
                    Text('${AppStrings.feelsLike} ${c.feelsLike.round()}°'),
                  ],
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(AppStrings.humidity, '${c.humidity}%'),
                _chip(AppStrings.wind, '${c.windSpeed.round()} km/h ${windCompass(c.windDirectionDegrees)}'),
                if (c.pressureMsl != null)
                  _chip(AppStrings.pressure, '${c.pressureMsl!.round()} hPa'),
                if (c.cloudCoverPercent != null)
                  _chip(AppStrings.cloudCover, '${c.cloudCoverPercent}%'),
                if (c.uvIndex != null)
                  _chip(AppStrings.uvIndex, c.uvIndex!.toStringAsFixed(1)),
              ],
            ),
            if (data.pollution.usAqi != null) ...[
              const SizedBox(height: 12),
              Text(AppStrings.pollutionTitle, style: theme.textTheme.titleSmall),
              Text('AQI ${data.pollution.usAqi}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) => Chip(label: Text('$label: $value'));
}

class HourlyForecastCard extends StatelessWidget {
  const HourlyForecastCard({super.key, required this.hourly});

  final List<HourForecast> hourly;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.hourlyTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...hourly.map(
              (h) => ListTile(
                dense: true,
                title: Text(DateFormat.jm().format(DateTime.parse(h.time))),
                trailing: Text('${h.temperature.round()}° ${weatherEmoji(h.weatherCode)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({super.key, required this.daily});

  final List<DayForecast> daily;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.dailyTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...daily.map(
              (d) => ListTile(
                dense: true,
                title: Text(d.date),
                subtitle: Text(dailyConditionLabel(d.weatherCode)),
                trailing: Text('${d.maxTemp.round()}° / ${d.minTemp.round()}°'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
