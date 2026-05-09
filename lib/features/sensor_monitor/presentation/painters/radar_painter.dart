import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Radar painter for LiDAR distance visualization
///
/// Features:
/// - Concentric grid circles
/// - Cross lines
/// - Animated sweep gradient
/// - Sweep line
/// - Detection blip
/// - Center dot
class RadarPainter extends CustomPainter {
  final double sweepAngle;
  final double distance;
  final double maxDistance;
  final Color color;

  RadarPainter({
    required this.sweepAngle,
    required this.distance,
    required this.maxDistance,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Draw grid circles
    _drawGridCircles(canvas, center, r);

    // Draw cross lines
    _drawCrossLines(canvas, center, r);

    // Draw sweep gradient
    _drawSweepGradient(canvas, center, r);

    // Draw sweep line
    _drawSweepLine(canvas, center, r);

    // Draw detected blip
    _drawDetectionBlip(canvas, center, r);

    // Draw center dot
    _drawCenterDot(canvas, center);
  }

  void _drawGridCircles(Canvas canvas, Offset center, double r) {
    final gridPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, r * i / 4, gridPaint);
    }
  }

  void _drawCrossLines(Canvas canvas, Offset center, double r) {
    final linePaint = Paint()
      ..color = color.withOpacity(0.12)
      ..strokeWidth = 0.8;

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - r, center.dy),
      Offset(center.dx + r, center.dy),
      linePaint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - r),
      Offset(center.dx, center.dy + r),
      linePaint,
    );
  }

  void _drawSweepGradient(Canvas canvas, Offset center, double r) {
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - 1.2,
        endAngle: sweepAngle,
        colors: [Colors.transparent, color.withOpacity(0.5)],
      ).createShader(Rect.fromCircle(center: center, radius: r))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, r, sweepPaint);
  }

  void _drawSweepLine(Canvas canvas, Offset center, double r) {
    final sweepLinePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      center,
      Offset(
        center.dx + r * math.cos(sweepAngle),
        center.dy + r * math.sin(sweepAngle),
      ),
      sweepLinePaint,
    );
  }

  void _drawDetectionBlip(Canvas canvas, Offset center, double r) {
    final blipDist = (distance / maxDistance).clamp(0.0, 1.0) * r;
    final blipPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final blipX = center.dx + blipDist * math.cos(sweepAngle - 0.3);
    final blipY = center.dy + blipDist * math.sin(sweepAngle - 0.3);

    // Inner blip
    canvas.drawCircle(Offset(blipX, blipY), 4, blipPaint);

    // Outer glow
    canvas.drawCircle(
      Offset(blipX, blipY),
      8,
      blipPaint..color = color.withOpacity(0.2),
    );
  }

  void _drawCenterDot(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.distance != distance;
  }
}
