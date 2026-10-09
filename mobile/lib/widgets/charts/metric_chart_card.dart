import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../../theme/weatherly_palette.dart';
import '../../theme/weatherly_responsive.dart';
import '../../theme/weatherly_theme.dart';

class MetricChartCard extends StatelessWidget {
  const MetricChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.subtitle,
    this.height,
    this.legend,
    this.showTouchHint = false,
  });

  final String title;
  final String? subtitle;
  final Widget chart;
  final double? height;
  final Widget? legend;
  final bool showTouchHint;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(lay.gapM, lay.gapM, lay.gapM, lay.gapM),
      decoration: weatherlyGlassDecoration(context: context, radius: lay.radiusM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: lay.sectionLabel(color: p.brandIndigo)),
          if (subtitle != null) ...[
            SizedBox(height: lay.gapXs / 2),
            Text(subtitle!, style: lay.textDayCondition),
          ],
          if (legend != null) ...[
            SizedBox(height: lay.gapS),
            legend!,
          ],
          if (showTouchHint) ...[
            SizedBox(height: lay.gapXs),
            Text(
              AppStrings.chartTouchHint,
              style: lay.sectionLabel(color: p.muted).copyWith(fontSize: lay.font(9)),
            ),
          ],
          SizedBox(height: lay.gapM),
          SizedBox(
            height: height ?? lay.font(200),
            child: chart,
          ),
        ],
      ),
    );
  }
}
