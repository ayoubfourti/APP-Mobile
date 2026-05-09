import 'package:flutter/material.dart';
import '../../disconnect_constants.dart';

class DisconnectStepIndicators extends StatelessWidget {
  const DisconnectStepIndicators({super.key, required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final total = DisconnectConstants.messages.length;

    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (i) {
            final active = progress.value > (i / total);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 32 : 24,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: active
                    ? DisconnectConstants.red
                    : const Color(0xFF330010),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: DisconnectConstants.red.withOpacity(0.7),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }
}