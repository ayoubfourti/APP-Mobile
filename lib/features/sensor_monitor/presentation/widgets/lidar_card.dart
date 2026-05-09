import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import '../painters/radar_painter.dart';
import 'card_shell.dart';
import 'card_label.dart';

class LidarCard extends StatelessWidget {
  final double distance;
  final Animation<double> radarAnim;
  final Animation<double> glowAnim;

  const LidarCard({
    super.key,
    required this.distance,
    required this.radarAnim,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    return CardShell(
      color: AppColors.cyan,
      height: 190,
      glowAnim: glowAnim,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardLabel(
              text: 'LIDAR DISTANCE',
              icon: Icons.radar_rounded,
              color: AppColors.cyan,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: radarAnim,
                  builder: (_, __) => CustomPaint(
                    size: const Size(110, 110),
                    painter: RadarPainter(
                      sweepAngle: radarAnim.value,
                      distance: distance,
                      maxDistance: 5.0,
                      color: AppColors.cyan,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '${distance.toStringAsFixed(2)} m',
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}