import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonBackgroundPainter extends CustomPainter {
  final double rotation;

  HexagonBackgroundPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (int i = 1; i <= 3; i++) {
      final radius = 80.0 * i;
      _drawHexagon(canvas, paint, radius);
    }

    canvas.restore();
  }

  void _drawHexagon(Canvas canvas, Paint paint, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2 / 6) - math.pi / 2;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HexagonBackgroundPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}