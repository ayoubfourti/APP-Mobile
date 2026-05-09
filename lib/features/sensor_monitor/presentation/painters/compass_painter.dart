import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Compass painter for IMU orientation visualization
///
/// Features:
/// - Outer ring decoration
/// - 16 cardinal direction ticks
/// - "N" label for North
/// - Animated needle (forward and backward)
/// - Decorative center cap
class CompassPainter extends CustomPainter {
  final double angleDeg;
  final Color color;

  CompassPainter({required this.angleDeg, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final angle = angleDeg * math.pi / 180;

    // Draw outer rings
    _drawOuterRings(canvas, center, r);

    // Draw cardinal ticks
    _drawCardinalTicks(canvas, center, r);

    // Draw North label
    _drawNorthLabel(canvas, center, r);

    // Draw needle
    _drawNeedle(canvas, center, r, angle);

    // Draw center cap
    _drawCenterCap(canvas, center);
  }

  void _drawOuterRings(Canvas canvas, Offset center, double r) {
    // Thin outer ring
    canvas.drawCircle(
      center,
      r - 2,
      Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Thick inner ring
    canvas.drawCircle(
      center,
      r - 8,
      Paint()
        ..color = color.withOpacity(0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
  }

  void _drawCardinalTicks(Canvas canvas, Offset center, double r) {
    final tickPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      // Longer ticks for cardinal directions (every 4)
      final inner = i % 4 == 0 ? r - 18 : r - 12;

      canvas.drawLine(
        Offset(
          center.dx + inner * math.cos(a),
          center.dy + inner * math.sin(a),
        ),
        Offset(
          center.dx + (r - 4) * math.cos(a),
          center.dy + (r - 4) * math.sin(a),
        ),
        tickPaint,
      );
    }
  }

  void _drawNorthLabel(Canvas canvas, Offset center, double r) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(center.dx - 6, center.dy - r + 16));
  }

  void _drawNeedle(Canvas canvas, Offset center, double r, double angle) {
    // Forward needle (main direction)
    final needlePaintFwd = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx + (r - 22) * math.sin(angle),
        center.dy - (r - 22) * math.cos(angle),
      ),
      needlePaintFwd,
    );

    // Backward needle (opposite direction, dimmed)
    final needlePaintBwd = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx - (r * 0.35) * math.sin(angle),
        center.dy + (r * 0.35) * math.cos(angle),
      ),
      needlePaintBwd,
    );
  }

  void _drawCenterCap(Canvas canvas, Offset center) {
    // Outer cap
    canvas.drawCircle(center, 5, Paint()..color = color);

    // Inner cap (dark background color)
    canvas.drawCircle(center, 3, Paint()..color = const Color(0xFF0A0E27));
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) {
    return oldDelegate.angleDeg != angleDeg;
  }
}
