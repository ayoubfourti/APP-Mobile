import 'package:flutter/material.dart';
import '../painters/grid_painter.dart';
import '../painters/hexagon_background_painter.dart';
import '../painters/particle_painter.dart';

/// Background animé réutilisable avec grille, hexagones et particules
class AnimatedTechBackground extends StatelessWidget {
  final double particleAnimation;
  final double rotateAnimation;
  final Widget child;

  const AnimatedTechBackground({
    super.key,
    required this.particleAnimation,
    required this.rotateAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient de fond
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

        // Grille animée
        CustomPaint(
          painter: GridPainter(animation: particleAnimation),
          size: Size.infinite,
        ),

        // Hexagones rotatifs
        CustomPaint(
          painter: HexagonBackgroundPainter(rotation: rotateAnimation),
          size: Size.infinite,
        ),

        // Particules flottantes
        CustomPaint(
          painter: ParticlePainter(animation: particleAnimation),
          size: Size.infinite,
        ),

        // Contenu
        child,
      ],
    );
  }
}