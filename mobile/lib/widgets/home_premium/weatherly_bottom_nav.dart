import 'package:flutter/material.dart';

import '../../theme/weatherly_palette.dart';
import '../../theme/weatherly_responsive.dart';

enum WeatherlyNavItem { dashboard, charts, assistant, cities }

class WeatherlyBottomNav extends StatelessWidget {
  const WeatherlyBottomNav({
    super.key,
    required this.active,
    required this.onSelect,
  });

  final WeatherlyNavItem active;
  final ValueChanged<WeatherlyNavItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        gradient: p.navBarGradient,
        border: Border(top: BorderSide(color: p.border)),
        boxShadow: p.navShadow,
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.symmetric(vertical: lay.gapXs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavButton(
              label: 'Dashboard',
              icon: Icons.wb_sunny_rounded,
              selected: active == WeatherlyNavItem.dashboard,
              onTap: () => onSelect(WeatherlyNavItem.dashboard),
            ),
            _NavButton(
              label: 'Charts',
              icon: Icons.show_chart_rounded,
              selected: active == WeatherlyNavItem.charts,
              onTap: () => onSelect(WeatherlyNavItem.charts),
            ),
            _NavButton(
              label: 'Assistant',
              icon: Icons.smart_toy_outlined,
              selected: active == WeatherlyNavItem.assistant,
              onTap: () => onSelect(WeatherlyNavItem.assistant),
            ),
            _NavButton(
              label: 'Cities',
              icon: Icons.location_city_outlined,
              selected: active == WeatherlyNavItem.cities,
              onTap: () => onSelect(WeatherlyNavItem.cities),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    if (selected) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(lay.radiusS),
          child: Ink(
            decoration: BoxDecoration(
              gradient: p.accentGradient,
              borderRadius: BorderRadius.circular(lay.radiusS),
              border: Border.all(color: p.accentBorder),
              boxShadow: p.glassShadow,
            ),
            padding: EdgeInsets.symmetric(horizontal: lay.gapM, vertical: lay.gapXs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: p.onAccent, size: lay.font(22)),
                SizedBox(height: lay.gapXs / 2),
                Text(label, style: lay.navLabel(color: p.gold)),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(lay.gapS),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: lay.gapS, vertical: lay.gapXs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: p.muted, size: lay.font(20)),
            SizedBox(height: lay.gapXs / 2),
            Text(label, style: lay.navLabel(color: p.muted)),
          ],
        ),
      ),
    );
  }
}
