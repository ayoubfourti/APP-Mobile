import 'package:flutter/material.dart';
import '../../../../core/widgets/painters/hexagon_painter.dart';

class StatusCard extends StatelessWidget {
  final AnimationController glowController;

  const StatusCard({
    super.key,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: glowController,
                builder: (context, child) {
                  final glowValue = glowController.value.clamp(0.0, 1.0);
                  return Container(
                    width: 50 + (glowValue * 10),
                    height: 50 + (glowValue * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00F5FF).withOpacity(0.1),
                    ),
                  );
                },
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00F5FF),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F5FF).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF0A0E27),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ROBOT STATUS",
                  style: TextStyle(
                    color: Color(0xFF00F5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Connected & Ready",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusDot(Colors.green),
                    const SizedBox(width: 5),
                    const Text(
                      "192.168.1.100:8080",
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(35, 35),
            painter: HexagonPainter(
              color: const Color(0xFF00F5FF).withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(Color color) {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        final glowValue = glowController.value.clamp(0.0, 1.0);
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(glowValue),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}