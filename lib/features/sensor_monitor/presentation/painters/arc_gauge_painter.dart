import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Painter pour dessiner une jauge en arc de cercle
class ArcGaugePainter extends CustomPainter {
  final double value; // 0.0 à 1.0
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
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Arc de fond (gris)
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi, // Commence à gauche (180°)
      math.pi, // Arc de 180°
      false,
      backgroundPaint,
    );

    // Arc de progression (couleur)
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.5),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi * value.clamp(0.0, 1.0), // Progression
      false,
      progressPaint,
    );

    // Point lumineux au bout de l'arc
    final angle = -math.pi + (math.pi * value.clamp(0.0, 1.0));
    final dotX = center.dx + radius * math.cos(angle);
    final dotY = center.dy + radius * math.sin(angle);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);

    // Halo lumineux
    final haloPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 10, haloPaint);

    // Texte au centre
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 + 10,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant ArcGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.label != label;
  }
}
