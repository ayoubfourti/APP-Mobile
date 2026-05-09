import 'package:flutter/material.dart';

class GasIndicatorWidget extends StatelessWidget {
  final bool gasDetected;

  const GasIndicatorWidget({
    super.key,
    required this.gasDetected,
  });

  @override
  Widget build(BuildContext context) {
    final color = gasDetected ? const Color(0xFFFF3D3D) : const Color(0xFF00FF88);
    final label = gasDetected ? 'GAZ DÉTECTÉ' : 'AIR NORMALE';
    final icon = gasDetected ? Icons.warning_amber_rounded : Icons.air;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}