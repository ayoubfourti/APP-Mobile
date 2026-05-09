import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexRingsPainter extends CustomPainter {
  final double rotation;
  final double progress;

  HexRingsPainter({required this.rotation, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (int i = 1; i <= 5; i++) {
      final r = 70.0 * i;
      final opacity = (0.02 + progress * 0.06) * (1 - i * 0.12);
      final paint = Paint()
        ..color = const Color(0xFFFF3232).withOpacity(opacity.clamp(0.005, 0.12))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      _drawHex(canvas, paint, r);
    }
    canvas.restore();
  }

  void _drawHex(Canvas canvas, Paint paint, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * math.pi * 2 / 6) - math.pi / 2;
      final pt = Offset(r * math.cos(a), r * math.sin(a));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HexRingsPainter old) =>
      old.rotation != rotation || old.progress != progress;
}