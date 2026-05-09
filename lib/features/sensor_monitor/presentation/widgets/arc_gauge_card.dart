import 'package:flutter/material.dart';
import '../painters/arc_gauge_painter.dart';
import 'card_shell.dart';
import 'card_label.dart';

class ArcGaugeCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final String unit;
  final Animation<double> glowAnim;

  const ArcGaugeCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.unit,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    return CardShell(
      color: color,
      height: 190,
      glowAnim: glowAnim,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardLabel(text: label, icon: icon, color: color),
            const SizedBox(height: 4),
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: const Size(110, 110),
                  painter: ArcGaugePainter(
                    value: value / 100,
                    color: color,
                    label: '${value.toStringAsFixed(0)}$unit',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}