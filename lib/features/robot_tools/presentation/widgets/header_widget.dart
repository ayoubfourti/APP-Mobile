import 'package:flutter/material.dart';
import 'dart:math' as math;

class HeaderWidget extends StatelessWidget {
  final AnimationController glowController;
  final AnimationController rotateController;
  final Animation<double> rotateAnimation;

  const HeaderWidget({
    super.key,
    required this.glowController,
    required this.rotateController,
    required this.rotateAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: glowController,
                builder: (context, child) {
                  final glowValue = glowController.value.clamp(0.0, 1.0);
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          const Color(0xFF00F5FF),
                          const Color(0xFF00D9FF),
                          const Color(0xFF00F5FF),
                        ],
                        stops: [0.0, glowValue, 1.0],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      "COMMAND CENTER",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              const Text(
                "All Systems Online",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF00F5FF),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00F5FF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: AnimatedBuilder(
              animation: rotateController,
              builder: (context, child) {
                final rotateValue = rotateAnimation.value.clamp(
                  0.0,
                  2 * math.pi,
                );
                return Transform.rotate(
                  angle: rotateValue * 0.5,
                  child: const Icon(
                    Icons.memory_rounded,
                    color: Color(0xFF00F5FF),
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}