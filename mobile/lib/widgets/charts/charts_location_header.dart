import 'package:flutter/material.dart';

import '../../models/weather_models.dart';
import '../../theme/weatherly_palette.dart';
import '../../theme/weatherly_responsive.dart';
import '../../theme/weatherly_theme.dart';

class ChartsLocationHeader extends StatelessWidget {
  const ChartsLocationHeader({super.key, required this.location});

  final LocationOption location;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        lay.pagePaddingH,
        lay.gapS,
        lay.pagePaddingH,
        lay.gapM,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: lay.gapM, vertical: lay.gapM),
        decoration: weatherlyGlassDecoration(context: context, radius: lay.radiusM),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(lay.gapS),
              decoration: BoxDecoration(
                gradient: p.accentGradient,
                borderRadius: BorderRadius.circular(lay.radiusS),
              ),
              child: Icon(Icons.place_rounded, color: p.onAccent, size: lay.font(20)),
            ),
            SizedBox(width: lay.gapM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: lay.textCityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: lay.gapXs / 2),
                  Text(
                    location.country.toUpperCase(),
                    style: lay.sectionLabel(color: p.accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
