import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/weather_chart_models.dart';
import '../models/weather_models.dart';
import '../theme/weatherly_palette.dart';
import '../theme/weatherly_responsive.dart';
import '../widgets/charts/charts_location_header.dart';
import '../widgets/charts/daily_charts.dart';
import '../widgets/charts/hourly_charts.dart';
import '../widgets/home_premium/dashboard_sections.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({
    super.key,
    required this.weather,
    required this.loading,
    required this.onRefresh,
    required this.onSettings,
    required this.onUseCurrentLocation,
    required this.locationBusy,
  });

  final WeatherResult? weather;
  final bool loading;
  final Future<void> Function() onRefresh;
  final VoidCallback onSettings;
  final VoidCallback onUseCurrentLocation;
  final bool locationBusy;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  ChartTimeRange _range = ChartTimeRange.hours24;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final weather = widget.weather;
    final lay = context.weatherly;

    return Container(
      decoration: BoxDecoration(gradient: palette.pageBackground),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: WeatherlyTopBar(
              title: AppStrings.chartsTitle,
              onSettings: widget.onSettings,
              onUseCurrentLocation: widget.onUseCurrentLocation,
              locationBusy: widget.locationBusy,
              useCurrentLocationTooltip: AppStrings.useCurrentLocation,
              settingsTooltip: AppStrings.settingsTitle,
            ),
          ),
          if (weather != null) ChartsLocationHeader(location: weather.location),
          Padding(
            padding: EdgeInsets.fromLTRB(
              lay.pagePaddingH,
              0,
              lay.pagePaddingH,
              lay.gapS,
            ),
            child: SegmentedButton<ChartTimeRange>(
              segments: ChartTimeRange.values
                  .map((r) => ButtonSegment(value: r, label: Text(r.label)))
                  .toList(),
              selected: {_range},
              onSelectionChanged: (s) => setState(() => _range = s.first),
            ),
          ),
          SizedBox(height: lay.gapS),
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: weather == null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: lay.sectionGap * 2),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: lay.pagePaddingH),
                          child: Text(
                            widget.loading
                                ? AppStrings.searchLoading
                                : AppStrings.chartsNeedWeather,
                            textAlign: TextAlign.center,
                            style: lay.textDayCondition,
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        lay.pagePaddingH,
                        lay.gapM,
                        lay.pagePaddingH,
                        lay.scrollBottomInset,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: _range.isHourly
                          ? buildHourlyChartSections(
                              context: context,
                              weather: weather,
                              hourWindow: _range.hourlyHours!,
                              sectionGap: lay.sectionGap,
                            )
                          : buildDailyChartSections(
                              context: context,
                              weather: weather,
                              sectionGap: lay.sectionGap,
                            ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
