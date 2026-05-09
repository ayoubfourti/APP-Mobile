import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../painters/compass_painter.dart';
import 'card_shell.dart';
import 'card_label.dart';

class CompassCard extends StatelessWidget {
  final double imu;
  final Animation<double> glowAnim;

  const CompassCard({
    super.key,
    required this.imu,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    return CardShell(
      color: AppColors.purple,
      height: 190,
      glowAnim: glowAnim,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardLabel(
              text: 'IMU ORIENTATION',
              icon: Icons.explore_rounded,
              color: AppColors.purple,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: const Size(110, 110),
                  painter: CompassPainter(
                    angleDeg: imu,
                    color: AppColors.purple,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '${imu.toStringAsFixed(1)}°',
                style: const TextStyle(
                  color: AppColors.purple,
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