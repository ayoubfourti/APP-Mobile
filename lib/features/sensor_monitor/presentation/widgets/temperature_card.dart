import 'package:flutter/material.dart';
import '../painters/temperature_gauge_painter.dart';
import 'card_shell.dart';
import 'card_label.dart';

class TemperatureCard extends StatelessWidget {
  final double temperature;
  final Color color;
  final Animation<double> glowAnim;

  const TemperatureCard({
    super.key,
    required this.temperature,
    required this.color,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    return CardShell(
      color: color,
      glowAnim: glowAnim,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: ArcGaugePainter(
                  value: ((temperature - 30) / 70).clamp(0.0, 1.0),
                  color: color,
                  label: "${temperature.toInt()}°",
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardLabel(
                    text: 'TEMPERATURE',
                    icon: Icons.thermostat_rounded,
                    color: color,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${temperature.toStringAsFixed(1)} °C',
                    style: TextStyle(
                      color: color,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    temperature > 80
                        ? '⚠ SURCHAUFFE'
                        : temperature > 60
                        ? '● CHAUD — SURVEILLER'
                        : '✔ NOMINAL',
                    style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
