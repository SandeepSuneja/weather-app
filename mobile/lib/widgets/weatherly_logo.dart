import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Light-theme mark from Figma (`mark-wrapper`, node 145:9).
class WeatherlyLogo extends StatelessWidget {
  const WeatherlyLogo({super.key, this.size = 40});

  final double size;

  static const String lightAsset = 'assets/images/logo_light.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      lightAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
