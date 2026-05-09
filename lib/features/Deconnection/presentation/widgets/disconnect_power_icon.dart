import 'package:flutter/material.dart';
import '../../disconnect_constants.dart';

class DisconnectPowerIcon extends StatelessWidget {
  const DisconnectPowerIcon({super.key, required this.pulse});

  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) {
        final p = pulse.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 130 + p * 22,
              height: 130 + p * 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DisconnectConstants.red.withOpacity(0.06 + p * 0.08),
              ),
            ),
            // Mid ring
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: DisconnectConstants.red.withOpacity(0.2 + p * 0.3),
                  width: 1,
                ),
              ),
            ),
            // Icon circle
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A0008),
                border: Border.all(color: DisconnectConstants.red, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: DisconnectConstants.red.withOpacity(0.5 + p * 0.3),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.power_settings_new_rounded,
                color: DisconnectConstants.red,
                size: 36,
              ),
            ),
          ],
        );
      },
    );
  }
}