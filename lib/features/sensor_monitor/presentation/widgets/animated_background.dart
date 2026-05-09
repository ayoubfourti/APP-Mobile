import 'package:flutter/material.dart';

import '../../../../core/widgets/painters/grid_painter.dart';
import '../../../../core/widgets/painters/hexagon_background_painter.dart';
import '../../../../core/widgets/painters/particle_painter.dart';


class AnimatedBackground extends StatelessWidget {
  final Animation<double> bgRotateAnim;
  final AnimationController bgParticleController;

  const AnimatedBackground({
    super.key,
    required this.bgRotateAnim,
    required this.bgParticleController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0A0E27),
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: bgParticleController,
          builder: (_, __) => CustomPaint(
            painter: GridPainter(animation: bgParticleController.value),
            size: Size.infinite,
          ),
        ),
        AnimatedBuilder(
          animation: bgRotateAnim,
          builder: (_, __) => CustomPaint(
            painter: HexagonBackgroundPainter(rotation: bgRotateAnim.value),
            size: Size.infinite,
          ),
        ),
        AnimatedBuilder(
          animation: bgParticleController,
          builder: (_, __) => CustomPaint(
            painter: ParticlePainter(animation: bgParticleController.value),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}