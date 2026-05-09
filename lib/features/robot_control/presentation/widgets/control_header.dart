// lib/features/robot_control/presentation/widgets/control_header.dart

import 'package:flutter/material.dart';

/// Header minimal avec titre et bouton retour
class ControlHeader extends StatelessWidget {
  const ControlHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.videocam_rounded,
            color: Color(0xFF00F5FF),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "CONTROL CENTER",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          _BackButton(),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ✅ maybePop → respecte PopScope du ControlRobotWrapper
      //    → déclenche onPopInvokedWithResult → affiche le dialog mission
      onTap: () => Navigator.maybePop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF00F5FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF00F5FF).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF00F5FF),
          size: 20,
        ),
      ),
    );
  }
}