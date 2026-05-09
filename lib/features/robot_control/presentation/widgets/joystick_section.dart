import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/control_state.dart';
import 'joystick_widget.dart';

class JoystickSection extends StatelessWidget {
  const JoystickSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ControlState>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // ── Titre seulement, bouton connexion supprimé ──
          const Text(
            "MOVEMENT",
            style: TextStyle(
              color: Color(0xFF00F5FF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 6),

          // ── Zone joystick ────────────────────────────
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00F5FF).withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                ),
                Opacity(
                  opacity: state.isConnected && !state.isAutoMode ? 1.0 : 0.4,
                  child: JoystickWidget(
                    onMove: (dx, dy) => state.updateJoystick(dx, dy),
                    onRelease: state.resetJoystick,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}