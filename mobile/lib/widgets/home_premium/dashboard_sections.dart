import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/weather_models.dart';
import '../../l10n/app_strings.dart';
import '../../theme/weatherly_palette.dart';
import '../../theme/weatherly_responsive.dart';
import '../../theme/weatherly_theme.dart';
import '../../utils/weather_hero_visual.dart';
import '../../utils/weather_insight.dart';
import '../../utils/weather_utils.dart';
import '../weatherly_logo.dart';
import 'hero_weather_background.dart';

class WeatherlyTopBar extends StatelessWidget {
  const WeatherlyTopBar({
    super.key,
    required this.title,
    required this.onSettings,
    this.onSaveLocation,
    this.locationSaved = false,
    this.saveTooltip,
    this.settingsTooltip,
  });

  final String title;
  final VoidCallback onSettings;
  final VoidCallback? onSaveLocation;
  final bool locationSaved;
  final String? saveTooltip;
  final String? settingsTooltip;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      height: lay.topBarHeight,
      padding: EdgeInsets.symmetric(horizontal: lay.pagePaddingH),
      decoration: BoxDecoration(
        gradient: p.topBarGradient,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          WeatherlyLogo(size: lay.logoSize),
          SizedBox(width: lay.gapS),
          Expanded(child: Text(title, style: lay.textAppTitle)),
          if (onSaveLocation != null)
            IconButton(
              onPressed: locationSaved ? null : onSaveLocation,
              tooltip: saveTooltip,
              icon: Icon(
                locationSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
                color: locationSaved ? p.muted : p.accent,
              ),
            ),
          IconButton(
            onPressed: onSettings,
            tooltip: settingsTooltip,
            icon: Icon(Icons.settings_outlined, color: p.ink),
          ),
        ],
      ),
    );
  }
}

class HeroWeatherSection extends StatelessWidget {
  const HeroWeatherSection({
    super.key,
    required this.data,
    required this.loading,
  });

  final WeatherResult? data;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final isNight = data != null && isNightAtLocation(data!);
    final visual = data != null
        ? heroVisualFor(data!.current.weatherCode, isNight: isNight)
        : defaultHeroVisual(context, isNight: false);

    final p = context.palette;
    return Container(
      height: lay.heroHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(lay.radiusL),
        border: Border.all(color: p.border),
        boxShadow: p.heroShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          HeroWeatherBackground(
            key: ValueKey(
              '${visual.scene.name}_${data?.current.weatherCode ?? 'loading'}_$isNight',
            ),
            visual: visual,
          ),
          if (loading && data == null)
            const Center(child: CircularProgressIndicator())
          else if (data != null)
            _HeroContent(data: data!, visual: visual),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.data,
    required this.visual,
  });

  final WeatherResult data;
  final WeatherHeroVisual visual;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final c = data.current;
    final temp = c.temperature.round();
    final isNight = isNightAtLocation(data);
    final p = context.palette;
    return Padding(
      padding: EdgeInsets.all(lay.pagePaddingH),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          _HeroConditionIcon(
            icon: visual.icon,
            color: visual.iconColor,
            isNight: isNight,
            size: lay.heroIconSize,
          ),
          SizedBox(height: lay.gapM),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [p.ink, p.heroTempGradientEnd],
            ).createShader(bounds),
            child: Text(
              '$temp°',
              style: lay.heroTemperature(color: p.onAccent),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: lay.gapXs),
          Text(
            weatherConditionSubtitle(c.weatherCode, isNight: isNight),
            style: lay.textHeroCondition,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: lay.sectionGap),
          Row(
            children: [
              Expanded(
                child: _HeroPill(
                  icon: Icons.air_rounded,
                  label: windDisplayMph(c.windSpeed, c.windDirectionDegrees),
                ),
              ),
              SizedBox(width: lay.gapM),
              Expanded(
                child: _HeroPill(
                  icon: Icons.water_drop_outlined,
                  label: '${c.humidity}%',
                ),
              ),
            ],
          ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _HeroLocationBadge(
              city: data.location.name,
              country: data.location.country,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroConditionIcon extends StatelessWidget {
  const _HeroConditionIcon({
    required this.icon,
    required this.color,
    required this.isNight,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final bool isNight;
  final double size;

  @override
  Widget build(BuildContext context) {
    final glow = isNight ? const Color(0xFF818CF8) : const Color(0xFFFFB347);
    return SizedBox(
      width: size * 1.35,
      height: size * 1.35,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.1,
            height: size * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: isNight ? 0.35 : 0.28),
                  blurRadius: size * 0.45,
                  spreadRadius: size * 0.02,
                ),
              ],
            ),
          ),
          Icon(icon, size: size, color: color),
        ],
      ),
    );
  }
}

class _HeroLocationBadge extends StatelessWidget {
  const _HeroLocationBadge({required this.city, required this.country});

  final String city;
  final String country;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: lay.gapM, vertical: lay.gapS),
      decoration: weatherlyGlassDecoration(context: context, radius: lay.radiusS).copyWith(
        boxShadow: [
          ...p.glassShadow,
          BoxShadow(
            color: p.accent.withValues(alpha: 0.12),
            blurRadius: lay.gapM,
            offset: Offset(0, lay.gapXs),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(lay.gapXs),
            decoration: BoxDecoration(
              gradient: p.accentGradient,
              borderRadius: BorderRadius.circular(lay.gapS),
            ),
            child: Icon(Icons.location_on_rounded, color: p.onAccent, size: lay.font(16)),
          ),
          SizedBox(width: lay.gapS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                city,
                style: lay.textHeroLocationCity,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                country.toUpperCase(),
                style: lay.textHeroLocationCountry,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      constraints: BoxConstraints(minHeight: lay.heroPillMinHeight),
      padding: EdgeInsets.symmetric(horizontal: lay.gapM, vertical: lay.gapS),
      decoration: weatherlyGlassDecoration(context: context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: lay.font(18), color: p.accent),
          SizedBox(width: lay.gapXs),
          Flexible(
            child: Text(
              label,
              style: lay.textHeroMetric,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key, required this.data});

  final WeatherResult data;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(lay.pagePaddingH),
      decoration: weatherlyGlassDecoration(
        context: context,
        radius: lay.radiusM,
        purple: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined, color: p.onAccent, size: lay.font(22)),
              SizedBox(width: lay.gapS),
              Text('AI WEATHER INSIGHT', style: lay.textAiCardTitle),
            ],
          ),
          SizedBox(height: lay.gapM),
          Text(buildWeatherInsight(data), style: lay.textAiQuote),
          SizedBox(height: lay.gapM),
          Text(
            'Live forecast summary',
            style: lay.aiFooter(color: p.insightFooter.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class MiniStatsGrid extends StatelessWidget {
  const MiniStatsGrid({super.key, required this.data});

  final WeatherResult data;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final today = data.daily.isNotEmpty ? data.daily.first : null;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: lay.gapM,
      crossAxisSpacing: lay.gapM,
      childAspectRatio: lay.statGridAspectRatio,
      children: [
        _StatTile(
          icon: Icons.wb_sunny_outlined,
          label: 'UV INDEX',
          value: uvIndexLabel(data.current.uvIndex),
        ),
        _StatTile(
          icon: Icons.visibility_outlined,
          label: 'VISIBILITY',
          value: data.current.cloudCoverPercent != null
              ? '${100 - data.current.cloudCoverPercent!}% clear'
              : '—',
        ),
        _StatTile(
          icon: Icons.wb_twilight,
          label: 'SUNRISE',
          value: _formatTime(today?.sunrise),
        ),
        _StatTile(
          icon: Icons.nightlight_round,
          label: 'SUNSET',
          value: _formatTime(today?.sunset),
        ),
      ],
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    return DateFormat.jm().format(dt.toLocal());
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      padding: EdgeInsets.all(lay.gapM),
      decoration: weatherlyGlassDecoration(context: context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: p.accent, size: lay.font(20)),
          SizedBox(height: lay.gapXs),
          Text(
            label,
            style: lay.sectionLabel().copyWith(
              color: p.muted.withValues(alpha: 0.7),
            ),
          ),
          Text(value, style: lay.textStatValue, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class HourlyForecastSection extends StatefulWidget {
  const HourlyForecastSection({
    super.key,
    required this.hourly,
  });

  final List<HourForecast> hourly;

  @override
  State<HourlyForecastSection> createState() => _HourlyForecastSectionState();
}

class _HourlyForecastSectionState extends State<HourlyForecastSection> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    if (widget.hourly.isEmpty) return const SizedBox.shrink();
    final lay = context.weatherly;
    final p = context.palette;
    final timeFmt = DateFormat('h a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: lay.gapXs),
          child: Text(AppStrings.hourlyTitle.toUpperCase(), style: lay.sectionLabel()),
        ),
        SizedBox(height: lay.gapM),
        SizedBox(
          height: lay.hourlyStripHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.hourly.length,
            separatorBuilder: (context, index) => SizedBox(width: lay.gapM),
            itemBuilder: (context, index) {
              final h = widget.hourly[index];
              final selected = index == _selected.clamp(0, widget.hourly.length - 1);
              final dt = DateTime.tryParse(h.time);
              final label = index == 0
                  ? 'NOW'
                  : (dt != null ? timeFmt.format(dt.toLocal()) : h.time);
              return GestureDetector(
                onTap: () => setState(() => _selected = index),
                child: Container(
                  width: lay.hourlyCardWidth,
                  padding: EdgeInsets.all(lay.gapM),
                  decoration: weatherlyGlassDecoration(
                    context: context,
                    purple: selected,
                    tightPurpleShadow: selected,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: lay.sectionLabel(
                          color: selected ? p.gold : p.muted,
                        ),
                      ),
                      SizedBox(height: lay.gapS),
                      Text(weatherEmoji(h.weatherCode), style: TextStyle(fontSize: lay.font(22))),
                      SizedBox(height: lay.gapS),
                      Text(
                        '${h.temperature.round()}°',
                        style: lay.hourlyTemp(
                          color: selected ? p.onAccent : p.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DailyForecastSection extends StatelessWidget {
  const DailyForecastSection({
    super.key,
    required this.daily,
  });

  final List<DayForecast> daily;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    final dayFmt = DateFormat.E();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: lay.gapXs),
          child: Text(AppStrings.dailyTitle.toUpperCase(), style: lay.sectionLabel()),
        ),
        SizedBox(height: lay.gapM),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(lay.radiusM),
            border: Border.all(color: p.border),
            gradient: p.glassCard,
            boxShadow: p.glassShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < daily.length; i++) ...[
                if (i > 0) Divider(height: 1, color: p.border),
                _DayRow(
                  dayLabel: i == 0
                      ? 'Today'
                      : dayFmt.format(DateTime.parse(daily[i].date)),
                  condition: dailyConditionLabel(daily[i].weatherCode),
                  code: daily[i].weatherCode,
                  high: daily[i].maxTemp.round(),
                  low: daily[i].minTemp.round(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.dayLabel,
    required this.condition,
    required this.code,
    required this.high,
    required this.low,
  });

  final String dayLabel;
  final String condition;
  final int code;
  final int high;
  final int low;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: lay.pagePaddingH,
        vertical: lay.gapM,
      ),
      child: Row(
        children: [
          SizedBox(
            width: lay.dayNameWidth,
            child: Text(dayLabel, style: lay.textDayName),
          ),
          Expanded(
            child: Row(
              children: [
                Text(weatherEmoji(code), style: TextStyle(fontSize: lay.font(22))),
                SizedBox(width: lay.gapS),
                Flexible(
                  child: Text(
                    condition,
                    style: lay.textDayCondition,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Text('$high°', style: lay.textStatValue),
          SizedBox(width: lay.gapM),
          Opacity(
            opacity: 0.45,
            child: Text('$low°', style: lay.textDayTempLow),
          ),
        ],
      ),
    );
  }
}

class RadarSnippetSection extends StatelessWidget {
  const RadarSnippetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        constraints: BoxConstraints(maxHeight: lay.radarHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(lay.radiusM),
          border: Border.all(color: p.border),
          boxShadow: p.glassShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/radar_map.png', fit: BoxFit.cover),
            Positioned(
              left: lay.gapM,
              bottom: lay.gapM,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: lay.gapM, vertical: lay.gapS),
                decoration: weatherlyGlassDecoration(
                  context: context,
                  radius: lay.radiusS,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: lay.font(18), color: p.accent),
                    SizedBox(width: lay.gapXs),
                    Text('EXPAND RADAR', style: lay.textChipLabel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
