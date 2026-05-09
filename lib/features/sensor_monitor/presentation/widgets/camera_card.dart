import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'card_shell.dart';
import 'card_label.dart';

class CameraCard extends StatelessWidget {
  final bool cameraActive;
  final Animation<double> cameraBlink;
  final Animation<double> glowAnim;

  const CameraCard({
    super.key,
    required this.cameraActive,
    required this.cameraBlink,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    final color = cameraActive ? AppColors.green : AppColors.red;
    
    return CardShell(
      color: color,
      height: 120,
      glowAnim: glowAnim,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardLabel(
              text: 'CAMERA STATUS',
              icon: Icons.videocam_rounded,
              color: color,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: cameraBlink,
                  builder: (context, child) => Text(
                    cameraActive ? 'ACTIVE' : 'OFFLINE',
                    style: TextStyle(
                      color: color.withOpacity(cameraActive ? cameraBlink.value : 1.0),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
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