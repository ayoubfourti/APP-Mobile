import 'package:flutter/material.dart';

class AutoModeButton extends StatelessWidget {
  final bool isAutoMode;
  final AnimationController glowController;
  final VoidCallback onToggle;

  const AutoModeButton({
    super.key,
    required this.isAutoMode,
    required this.glowController,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedBuilder(
        animation: glowController,
        builder: (context, child) {
          final glowValue = glowController.value.clamp(0.0, 1.0);

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8), // ✅ réduit (était 16)
            decoration: _buildDecoration(glowValue),
            child: _buildContent(),
          );
        },
      ),
    );
  }

  BoxDecoration _buildDecoration(double glowValue) {
    return BoxDecoration(
      gradient: isAutoMode
          ? const LinearGradient(
              colors: [Color(0xFF00F5FF), Color(0xFF00D9FF), Color(0xFF00BFFF)],
            )
          : null,
      color: isAutoMode ? null : const Color(0xFF1A1A2E).withOpacity(0.6),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: isAutoMode
            ? const Color(0xFF00F5FF)
            : const Color(0xFF00F5FF).withOpacity(0.3),
        width: isAutoMode ? 2 : 1.5,
      ),
      boxShadow: isAutoMode
          ? [
              BoxShadow(
                color: const Color(0xFF00F5FF).withOpacity(0.3 + glowValue * 0.2),
                blurRadius: 20 + (glowValue * 10),
                spreadRadius: 0,
              ),
            ]
          : [],
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isAutoMode ? Icons.smart_toy_rounded : Icons.smart_toy_outlined,
          color: isAutoMode ? const Color(0xFF0A0E27) : const Color(0xFF00F5FF),
          size: 28, // ✅ légèrement réduit (était 32)
        ),
        const SizedBox(width: 12),
        Text(
          isAutoMode ? "AUTO MODE ACTIVE" : "ENABLE AUTO MODE",
          style: TextStyle(
            color: isAutoMode ? const Color(0xFF0A0E27) : const Color(0xFF00F5FF),
            fontSize: 15, // ✅ légèrement réduit (était 16)
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        if (isAutoMode) ...[const SizedBox(width: 12), _buildPulseIndicator()],
      ],
    );
  }

  Widget _buildPulseIndicator() {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        final glowValue = glowController.value.clamp(0.0, 1.0);
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A0E27),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A0E27).withOpacity(glowValue),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}