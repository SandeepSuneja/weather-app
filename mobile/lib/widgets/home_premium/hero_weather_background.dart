import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../utils/weather_hero_visual.dart';

/// Soft, one-shot hero atmosphere keyed to weather scene and local day/night.
class HeroWeatherBackground extends StatefulWidget {
  const HeroWeatherBackground({
    super.key,
    required this.visual,
  });

  final WeatherHeroVisual visual;

  @override
  State<HeroWeatherBackground> createState() => _HeroWeatherBackgroundState();
}

class _HeroWeatherBackgroundState extends State<HeroWeatherBackground>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2800);

  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 1, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant HeroWeatherBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    final v = widget.visual;
    final o = oldWidget.visual;
    if (v.scene != o.scene || v.isNight != o.isNight) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visual = widget.visual;
    final t = _progress.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: visual.gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: visual.colorFilter,
            child: Opacity(
              opacity: visual.textureOpacity * (0.25 + 0.75 * t),
              child: Image.asset(
                'assets/images/hero_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              return CustomPaint(
                painter: _WeatherScenePainter(
                  scene: visual.scene,
                  isNight: visual.isNight,
                  progress: _progress.value,
                ),
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: visual.isNight ? 0.03 : 0.12),
                  Colors.transparent,
                  Colors.black.withValues(alpha: visual.isNight ? 0.18 : 0.06),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherScenePainter extends CustomPainter {
  _WeatherScenePainter({
    required this.scene,
    required this.isNight,
    required this.progress,
  });

  final WeatherHeroScene scene;
  final bool isNight;
  final double progress;

  double get _t => Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    if (isNight && (scene == WeatherHeroScene.clear || scene == WeatherHeroScene.mainlyClear)) {
      _paintNightSky(canvas, size);
      return;
    }
    if (isNight && scene == WeatherHeroScene.cloudy) {
      _paintLayeredClouds(canvas, size, night: true);
      return;
    }

    switch (scene) {
      case WeatherHeroScene.clear:
        _paintSunriseRays(canvas, size);
      case WeatherHeroScene.mainlyClear:
        _paintSoftRainbow(canvas, size);
      case WeatherHeroScene.cloudy:
        _paintLayeredClouds(canvas, size, night: false);
      case WeatherHeroScene.rain:
        _paintRain(canvas, size);
      case WeatherHeroScene.snow:
        _paintSnow(canvas, size);
      case WeatherHeroScene.storm:
        _paintStorm(canvas, size);
    }
  }

  void _paintNightSky(Canvas canvas, Size size) {
    final starT = Curves.easeOut.transform(_t);
    final rnd = math.Random(7);
    for (var i = 0; i < 42; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.72;
      final phase = rnd.nextDouble();
      final twinkle = ((starT + phase) % 1.0);
      final alpha = (0.15 + 0.55 * math.sin(twinkle * math.pi)).clamp(0.0, 1.0) * starT;
      final r = 0.6 + rnd.nextDouble() * 1.4;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withValues(alpha: alpha * 0.9),
      );
    }

    final moonCenter = Offset(size.width * 0.78, size.height * 0.2);
    final moonR = size.width * (0.07 + 0.03 * _t);
    final moonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFEF9C3).withValues(alpha: 0.5 * _t),
          const Color(0xFF818CF8).withValues(alpha: 0.08 * _t),
          Colors.transparent,
        ],
        stops: const [0, 0.35, 1],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonR * 3.2));
    canvas.drawCircle(moonCenter, moonR * 3.2, moonGlow);

    canvas.drawCircle(
      moonCenter,
      moonR,
      Paint()..color = const Color(0xFFFEF3C7).withValues(alpha: 0.92 * _t),
    );
    canvas.drawCircle(
      moonCenter + Offset(moonR * 0.38, -moonR * 0.08),
      moonR * 0.88,
      Paint()..color = const Color(0xFF1E1B4B).withValues(alpha: 0.98),
    );
  }

  void _paintSunriseRays(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.85, size.height * 0.05);
    final rayPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topRight,
        radius: 1.1,
        colors: [
          const Color(0xFFFFE082).withValues(alpha: 0.45 * _t),
          const Color(0xFFFFAB40).withValues(alpha: 0.12 * _t),
          Colors.transparent,
        ],
        stops: const [0, 0.35, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, rayPaint);

    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i - 2) * 0.12;
      final len = size.height * (0.35 + 0.25 * _t);
      final end = origin + Offset(math.cos(angle) * len, math.sin(angle) * len);
      final p = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFE082).withValues(alpha: 0.35 * _t),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(origin, end))
        ..strokeWidth = size.width * 0.08
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawLine(origin, end, p);
    }
  }

  void _paintSoftRainbow(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(-size.width * 0.05, size.height * 0.08, size.width * 1.1, size.height * 0.52);
    final sweep = math.pi * 0.92 * _t;
    const bands = [
      Color(0x33FCA5A5),
      Color(0x33FCD34D),
      Color(0x3386EFAC),
      Color(0x3393C5FD),
      Color(0x33C4B5FD),
    ];
    for (var i = 0; i < bands.length; i++) {
      final inset = i * (size.width * 0.012);
      final r = rect.deflate(inset);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.028
        ..strokeCap = StrokeCap.round
        ..color = bands[i].withValues(alpha: 0.22 * _t);
      canvas.drawArc(r, -math.pi, sweep, false, paint);
    }
  }

  void _paintLayeredClouds(Canvas canvas, Size size, {required bool night}) {
    final scale = night ? 0.55 : 1.0;
    _softCloud(canvas, size, Offset.lerp(
      Offset(-size.width * 0.25, size.height * 0.18),
      Offset(size.width * 0.08, size.height * 0.18),
      _t,
    )!, size.width * 0.36, 0.42 * _t * scale, night: night);
    _softCloud(canvas, size, Offset.lerp(
      Offset(size.width * 0.95, size.height * 0.32),
      Offset(size.width * 0.48, size.height * 0.32),
      _t,
    )!, size.width * 0.42, 0.36 * _t * scale, night: night);
    _softCloud(canvas, size, Offset.lerp(
      Offset(-size.width * 0.1, size.height * 0.48),
      Offset(size.width * 0.22, size.height * 0.48),
      _t,
    )!, size.width * 0.28, 0.28 * _t * scale, night: night);
  }

  void _softCloud(
    Canvas canvas,
    Size size,
    Offset center,
    double width,
    double opacity, {
    bool night = false,
  }) {
    if (opacity <= 0.01) return;
    final h = width * 0.38;
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: night
            ? [
                const Color(0xFF94A3B8).withValues(alpha: opacity * 0.9),
                const Color(0xFF64748B).withValues(alpha: opacity * 0.45),
              ]
            : [
                Colors.white.withValues(alpha: opacity),
                Colors.white.withValues(alpha: opacity * 0.55),
              ],
      ).createShader(Rect.fromCenter(center: center, width: width, height: h))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (final dx in [-0.28, 0, 0.26]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(width * dx, h * 0.06),
          width: width * (dx == 0 ? 1 : 0.55),
          height: h * (dx == 0 ? 1 : 0.85),
        ),
        base,
      );
    }
  }

  void _paintRain(Canvas canvas, Size size) {
    final angle = -math.pi / 10;
    final dx = math.cos(angle) * 18;
    final dy = math.sin(angle) * 18;
    final rnd = math.Random(11);
    for (var i = 0; i < 28; i++) {
      final x0 = rnd.nextDouble() * size.width;
      final phase = rnd.nextDouble();
      final y0 = lerpDouble(-60, size.height * 0.75, (_t * (0.85 + phase * 0.15)).clamp(0.0, 1.0))!;
      final len = 10.0 + rnd.nextDouble() * 14;
      final alpha = (0.25 + 0.45 * _t) * (0.6 + 0.4 * rnd.nextDouble());
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFE0F2FE).withValues(alpha: 0),
            const Color(0xFFBAE6FD).withValues(alpha: alpha),
            const Color(0xFF7DD3FC).withValues(alpha: alpha * 0.3),
          ],
        ).createShader(Rect.fromLTWH(x0, y0, dx, dy + len))
        ..strokeWidth = 1.2 + rnd.nextDouble() * 0.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x0, y0), Offset(x0 + dx, y0 + dy + len), paint);
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final rnd = math.Random(19);
    for (var i = 0; i < 36; i++) {
      final x = rnd.nextDouble() * size.width;
      final phase = rnd.nextDouble();
      final drift = math.sin(phase * math.pi * 2 + _t * math.pi) * 8;
      final y = lerpDouble(-30, size.height * 0.9, (_t * (0.7 + phase * 0.3)).clamp(0.0, 1.0))! + phase * 20;
      final r = 1.2 + rnd.nextDouble() * 2.8;
      final alpha = (0.35 + 0.5 * _t) * (0.5 + 0.5 * rnd.nextDouble());
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(x + drift, y), r, paint);
    }
  }

  void _paintStorm(Canvas canvas, Size size) {
    final t = progress;
    double flash = 0;
    if (t < 0.08) {
      flash = Curves.easeOut.transform(t / 0.08) * 0.28;
    } else if (t < 0.14) {
      flash = (1 - Curves.easeIn.transform((t - 0.08) / 0.06)) * 0.12;
    } else if (t > 0.32 && t < 0.4) {
      flash = Curves.easeOut.transform((t - 0.32) / 0.08) * 0.22;
    }
    if (flash > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFE0E7FF).withValues(alpha: flash),
      );
    }

    if (_t > 0.12) {
      final bolt = Path()
        ..moveTo(size.width * 0.58, size.height * 0.06)
        ..cubicTo(
          size.width * 0.52,
          size.height * 0.22,
          size.width * 0.62,
          size.height * 0.28,
          size.width * 0.54,
          size.height * 0.42,
        )
        ..cubicTo(
          size.width * 0.48,
          size.height * 0.52,
          size.width * 0.58,
          size.height * 0.54,
          size.width * 0.46,
          size.height * 0.78,
        );
      final glow = Paint()
        ..color = const Color(0xFFFDE68A).withValues(alpha: 0.35 * _t)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(bolt, glow);
      canvas.drawPath(
        bolt,
        Paint()
          ..color = const Color(0xFFFEF9C3).withValues(alpha: 0.92 * _t)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherScenePainter oldDelegate) {
    return oldDelegate.scene != scene ||
        oldDelegate.isNight != isNight ||
        oldDelegate.progress != progress;
  }
}
