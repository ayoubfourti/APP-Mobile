import 'package:flutter/material.dart';

class ScanLinePainter extends CustomPainter {
  final double t;
  final Size size;

  ScanLinePainter({required this.t, required this.size});

  @override
  void paint(Canvas canvas, Size _) {
    final y = t * size.height;

    // Soft gradient glow around the line
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFFF3232).withOpacity(0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 60, size.width, 120));
    canvas.drawRect(Rect.fromLTWH(0, y - 60, size.width, 120), glowPaint);

    // Sharp leading edge
    final linePaint = Paint()
      ..color = const Color(0xFFFF3232).withOpacity(0.65)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(ScanLinePainter old) => old.t != t;
}