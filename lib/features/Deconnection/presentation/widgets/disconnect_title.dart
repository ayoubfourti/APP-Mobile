import 'package:flutter/material.dart';
import '../../disconnect_constants.dart';

class DisconnectTitle extends StatelessWidget {
  const DisconnectTitle({
    super.key,
    required this.showGlitch,
    required this.dx,
    required this.dy,
  });

  final bool showGlitch;
  final double dx;
  final double dy;

  static const TextStyle _base = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    letterSpacing: 5,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cyan ghost — glitch layer 1
        if (showGlitch)
          Transform.translate(
            offset: Offset(dx, dy),
            child: Text(
              "DISCONNECTING",
              style: _base.copyWith(
                color: DisconnectConstants.cyan.withOpacity(0.6),
              ),
            ),
          ),

        // Red ghost — glitch layer 2
        if (showGlitch)
          Transform.translate(
            offset: Offset(-dx * 0.7, -dy),
            child: Text(
              "DISCONNECTING",
              style: _base.copyWith(
                color: DisconnectConstants.red.withOpacity(0.6),
              ),
            ),
          ),

        // Base text
        Text(
          "DISCONNECTING",
          style: _base.copyWith(
            color: Colors.white,
            shadows: [
              Shadow(
                color: DisconnectConstants.red.withOpacity(0.7),
                blurRadius: 24,
              ),
              Shadow(
                color: DisconnectConstants.red.withOpacity(0.3),
                blurRadius: 60,
              ),
            ],
          ),
        ),
      ],
    );
  }
}