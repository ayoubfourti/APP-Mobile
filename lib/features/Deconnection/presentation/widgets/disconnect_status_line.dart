import 'package:flutter/material.dart';
import '../../disconnect_constants.dart';

class DisconnectStatusLine extends StatelessWidget {
  const DisconnectStatusLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: Text(
          text,
          key: ValueKey(text),
          style: const TextStyle(
            color: DisconnectConstants.red,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}