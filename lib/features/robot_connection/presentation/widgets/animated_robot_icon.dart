import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/widgets/painters/hexagon_painter.dart';

class AnimatedRobotIcon extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final Animation<double> rotateAnimation;

  const AnimatedRobotIcon({
    super.key,
    required this.pulseAnimation,
    required this.rotateAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercle pulsant
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (_, __) => Container(
            width: 200 * pulseAnimation.value.clamp(0.0, 2.0),
            height: 200 * pulseAnimation.value.clamp(0.0, 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00F5FF).withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
        ),

        // Hexagone rotatif
        AnimatedBuilder(
          animation: rotateAnimation,
          builder: (_, __) => Transform.rotate(
            angle: rotateAnimation.value.clamp(0.0, 2 * math.pi),
            child: CustomPaint(
              size: const Size(160, 160),
              painter: HexagonPainter(
                color: const Color(0xFF00F5FF).withOpacity(0.2),
              ),
            ),
          ),
        ),

        // Icône centrale
        ScaleTransition(
          scale: pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00F5FF).withOpacity(0.3),
                  const Color(0xFF00F5FF).withOpacity(0.0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F5FF).withOpacity(0.5),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.precision_manufacturing_rounded,
              size: 100,
              color: Color(0xFF00F5FF),
            ),
          ),
        ),

        // Points rotatifs
        AnimatedBuilder(
          animation: rotateAnimation,
          builder: (_, __) => Transform.rotate(
            angle: -rotateAnimation.value.clamp(0.0, 2 * math.pi) * 2,
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                children: List.generate(6, (index) {
                  final angle = (index * math.pi * 2 / 6);
                  return Positioned(
                    left: 90 + 80 * math.cos(angle) - 4,
                    top: 90 + 80 * math.sin(angle) - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00F5FF),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F5FF).withOpacity(0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
