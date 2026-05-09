import 'package:flutter/material.dart';
import '../../../../core/widgets/painters/hexagon_painter.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(40, 40),
          painter: HexagonPainter(
            color: const Color(0xFF00F5FF).withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "EMERGENCY ROBOTICS SYSTEM",
          style: TextStyle(
            color: Color(0xFF00F5FF),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "v1.0 • CLASSIFIED",
          style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1),
        ),
      ],
    );
  }
}