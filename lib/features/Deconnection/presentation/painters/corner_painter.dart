import 'package:flutter/material.dart';

class CornerPainter extends CustomPainter {
  final bool isLeft;
  final bool isTop;
  final Color color;

  CornerPainter({
    required this.isLeft,
    required this.isTop,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;

    final path = Path();
    if (isLeft && isTop) {
      path.moveTo(w, 0);
      path.lineTo(0, 0);
      path.lineTo(0, h);
    } else if (!isLeft && isTop) {
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      path.lineTo(w, h);
    } else if (isLeft && !isTop) {
      path.moveTo(w, h);
      path.lineTo(0, h);
      path.lineTo(0, 0);
    } else {
      path.moveTo(0, h);
      path.lineTo(w, h);
      path.lineTo(w, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CornerPainter old) => false;
}