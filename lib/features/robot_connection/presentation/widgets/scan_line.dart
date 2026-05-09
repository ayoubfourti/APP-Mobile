import 'package:flutter/material.dart';

class ScanLine extends StatelessWidget {
  final AnimationController scanController;

  const ScanLine({super.key, required this.scanController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scanController,
      builder: (_, __) {
        final scanValue = scanController.value.clamp(0.0, 1.0);
        return Container(
          width: 200,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFF00F5FF).withOpacity(scanValue),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}