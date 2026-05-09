// lib/features/disconnect/presentation/widgets/disconnect_progress_bar.dart
import 'package:flutter/material.dart';
import '../../disconnect_constants.dart';

class DisconnectProgressBar extends StatelessWidget {
  const DisconnectProgressBar({super.key, required this.progress});
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("SHUTDOWN SEQUENCE",
                  style: TextStyle(color: Color(0xFF883333), fontSize: 9, letterSpacing: 2)),
              AnimatedBuilder(
                animation: progress,
                builder: (_, __) => Text(
                  "${(progress.value * 100).toInt()}%",
                  style: const TextStyle(color: DisconnectConstants.red,
                      fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: progress,
            builder: (_, __) {
              final v = progress.value.clamp(0.0, 1.0);
              return ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Stack(children: [
                  Container(height: 5,
                      decoration: BoxDecoration(color: const Color(0xFF2A0010),
                          borderRadius: BorderRadius.circular(2))),
                  FractionallySizedBox(
                    widthFactor: v,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFAA1111), DisconnectConstants.red]),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [BoxShadow(
                            color: DisconnectConstants.red.withOpacity(0.8),
                            blurRadius: 12, spreadRadius: 2)],
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}