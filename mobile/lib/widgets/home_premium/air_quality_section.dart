import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../../models/weather_models.dart';
import '../../theme/weatherly_palette.dart';
import '../../theme/weatherly_responsive.dart';
import '../../theme/weatherly_theme.dart';
import '../../utils/air_quality_utils.dart';

class AirQualitySection extends StatelessWidget {
  const AirQualitySection({super.key, required this.pollution});

  final PollutionData pollution;

  @override
  Widget build(BuildContext context) {
    if (!pollutionHasReadings(pollution)) {
      return _AirQualityUnavailable();
    }

    final lay = context.weatherly;
    final p = context.palette;
    final aqi = pollution.usAqi;
    final category = aqi != null ? aqiCategoryFor(aqi) : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(lay.pagePaddingH),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(lay.radiusM),
        gradient: p.glassCard,
        border: Border.all(
          color: category?.color.withValues(alpha: 0.45) ?? p.border,
          width: category != null ? 1.5 : 1,
        ),
        boxShadow: [
          ...p.glassShadow,
          if (category != null)
            BoxShadow(
              color: category.color.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.air_rounded, color: category?.color ?? p.accent, size: lay.font(22)),
              SizedBox(width: lay.gapS),
              Text(
                AppStrings.pollutionTitle.toUpperCase(),
                style: lay.sectionLabel(color: p.brandIndigo),
              ),
            ],
          ),
          SizedBox(height: lay.gapM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (aqi != null && category != null) ...[
                _AqiBadge(aqi: aqi, category: category),
                SizedBox(width: lay.gapM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category != null) ...[
                      Text(category.label, style: lay.textStatValue),
                      SizedBox(height: lay.gapXs),
                      Text(
                        category.shortDescription,
                        style: lay.textDayCondition,
                      ),
                      SizedBox(height: lay.gapM),
                      _AqiScaleBar(progress: aqiProgress(aqi!), accent: category.color),
                    ] else
                      Text(
                        AppStrings.pollutionPartialHint,
                        style: lay.textDayCondition,
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: lay.gapM),
          Wrap(
            spacing: lay.gapS,
            runSpacing: lay.gapS,
            children: [
              _PollutantChip(
                label: AppStrings.pollutionPm25,
                value: formatPollutantMicrograms(pollution.pm2_5),
                unit: AppStrings.pollutionUnitUg,
              ),
              _PollutantChip(
                label: AppStrings.pollutionPm10,
                value: formatPollutantMicrograms(pollution.pm10),
                unit: AppStrings.pollutionUnitUg,
              ),
              _PollutantChip(
                label: AppStrings.pollutionNo2,
                value: formatPollutantMicrograms(pollution.nitrogenDioxide),
                unit: AppStrings.pollutionUnitUg,
              ),
              _PollutantChip(
                label: AppStrings.pollutionO3,
                value: formatPollutantMicrograms(pollution.ozone),
                unit: AppStrings.pollutionUnitUg,
              ),
              _PollutantChip(
                label: AppStrings.pollutionCo,
                value: formatPollutantMicrograms(pollution.carbonMonoxide),
                unit: AppStrings.pollutionUnitUg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AqiBadge extends StatelessWidget {
  const _AqiBadge({required this.aqi, required this.category});

  final int aqi;
  final AqiCategory category;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    final size = lay.font(88);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: aqiProgress(aqi),
              strokeWidth: lay.font(6),
              backgroundColor: p.border.withValues(alpha: 0.35),
              color: category.color,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$aqi',
                style: lay.textStatValue.copyWith(
                  fontSize: lay.font(28),
                  height: 1,
                ),
              ),
              Text(
                AppStrings.pollutionAqiLabel,
                style: lay.sectionLabel(color: p.muted).copyWith(fontSize: lay.font(10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AqiScaleBar extends StatelessWidget {
  const _AqiScaleBar({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(lay.gapXs),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: lay.gapXs,
            backgroundColor: p.border.withValues(alpha: 0.4),
            color: accent,
          ),
        ),
        SizedBox(height: lay.gapXs / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: lay.sectionLabel().copyWith(fontSize: lay.font(9))),
            Text('300+', style: lay.sectionLabel().copyWith(fontSize: lay.font(9))),
          ],
        ),
      ],
    );
  }
}

class _PollutantChip extends StatelessWidget {
  const _PollutantChip({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: lay.gapM, vertical: lay.gapS),
      decoration: weatherlyGlassDecoration(context: context, radius: lay.radiusS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: lay.sectionLabel(color: p.muted).copyWith(fontSize: lay.font(10)),
          ),
          SizedBox(height: lay.gapXs / 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: lay.textStatValue.copyWith(fontSize: lay.font(16))),
              SizedBox(width: lay.gapXs / 2),
              Text(
                unit,
                style: lay.sectionLabel(color: p.muted).copyWith(fontSize: lay.font(9)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AirQualityUnavailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(lay.pagePaddingH),
      decoration: weatherlyGlassDecoration(context: context, radius: lay.radiusM),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: p.muted, size: lay.font(22)),
          SizedBox(width: lay.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.pollutionTitle, style: lay.textStatValue),
                SizedBox(height: lay.gapXs),
                Text(AppStrings.aqiUnavailable, style: lay.textDayCondition),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
