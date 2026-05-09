import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticlePainter extends CustomPainter {
  final double t;
  final Size size;

  ParticlePainter({required this.t, required this.size});

  @override
  void paint(Canvas canvas, Size _) {
    final rng = math.Random(77); // fixed seed = stable positions
    final paint = Paint()
      ..color = const Color(0xFFFF3232).withOpacity(0.35)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.1 + rng.nextDouble() * 0.25;
      final y = (baseY + t * size.height * speed) % size.height;
      final r = 1.0 + rng.nextDouble() * 1.5;
      canvas.drawCircle(Offset(baseX, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) => old.t != t;
}