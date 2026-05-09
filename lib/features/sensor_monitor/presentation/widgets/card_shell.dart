import 'package:flutter/material.dart';

class CardShell extends StatelessWidget {
  final Color color;
  final Widget child;
  final double? height;
  final Animation<double> glowAnim;

  const CardShell({
    super.key,
    required this.color,
    required this.child,
    required this.glowAnim,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) => Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withOpacity(0.04),
          border: Border.all(color: color.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08 * glowAnim.value),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
