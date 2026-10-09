import 'package:flutter/material.dart';

import '../../theme/weatherly_palette.dart';
import '../../theme/weatherly_responsive.dart';

class ChartLegendEntry {
  const ChartLegendEntry({
    required this.label,
    required this.color,
    this.dashed = false,
  });

  final String label;
  final Color color;
  final bool dashed;
}

class ChartLegendRow extends StatelessWidget {
  const ChartLegendRow({super.key, required this.entries});

  final List<ChartLegendEntry> entries;

  @override
  Widget build(BuildContext context) {
    final lay = context.weatherly;
    final p = context.palette;
    return Wrap(
      spacing: lay.gapM,
      runSpacing: lay.gapXs,
      children: [
        for (final e in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Swatch(color: e.color, dashed: e.dashed),
              SizedBox(width: lay.gapXs),
              Text(
                e.label,
                style: lay.sectionLabel(color: p.muted).copyWith(fontSize: lay.font(10)),
              ),
            ],
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    if (dashed) {
      return CustomPaint(
        size: const Size(20, 3),
        painter: _DashedLinePainter(color: color),
      );
    }
    return Container(
      width: 14,
      height: 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      final end = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, size.height / 2), Offset(end, size.height / 2), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
