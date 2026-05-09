import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

/// Arc gauge painter for displaying percentage-based metrics
///
/// Features:
/// - Background track arc
/// - Animated value arc with glow
/// - Centered value label
/// - 270-degree arc (3/4 circle)
///
/// Used for: CPU usage, GPU usage, or any 0-100% metric
class ArcGaugePainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final Color color;
  final String label;

  ArcGaugePainter({
    required this.value,
    required this.color,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;

    const startAngle = math.pi * 0.75; // Start at 135 degrees
    const sweepTotal = math.pi * 1.5; // 270 degrees total

    // Draw background track
    _drawTrack(canvas, center, r, startAngle, sweepTotal);

    // Draw value arc
    _drawValueArc(canvas, center, r, startAngle, sweepTotal);

    // Draw value label
    _drawLabel(canvas, center);
  }

  void _drawTrack(
    Canvas canvas,
    Offset center,
    double r,
    double startAngle,
    double sweepTotal,
  ) {
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawValueArc(
    Canvas canvas,
    Offset center,
    double r,
    double startAngle,
    double sweepTotal,
  ) {
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      startAngle,
      sweepTotal * value.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
    );
  }

  void _drawLabel(Canvas canvas, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(ArcGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.label != label;
  }
}
