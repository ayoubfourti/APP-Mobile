import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticlePainter extends CustomPainter {
  final double animation;

  ParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + animation * size.height * 0.3) % size.height;
      final radius = 1 + random.nextDouble() * 2;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}