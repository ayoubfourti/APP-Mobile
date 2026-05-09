import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double animation;

  GridPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.05)
      ..strokeWidth = 1;

    final spacing = 40.0;
    final offset = animation * spacing;

    for (double x = -spacing + offset; x < size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = -spacing + offset; y < size.height + spacing; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}