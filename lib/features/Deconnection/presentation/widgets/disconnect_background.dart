import 'package:flutter/material.dart';
import '../../disconnect_constants.dart';

class DisconnectBackground extends StatelessWidget {
  const DisconnectBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.4,
          colors: [
            Color(0xFF1A0010),
            Color(0xFF0A0008),
            DisconnectConstants.bg,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}