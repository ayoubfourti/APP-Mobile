import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'card_shell.dart';
import 'card_label.dart';

class BatteryCard extends StatelessWidget {
  final double battery;
  final Color color;
  final Animation<double> pulseAnim;
  final Animation<double> glowAnim;

  const BatteryCard({
    super.key,
    required this.battery,
    required this.color,
    required this.pulseAnim,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    final bool warn = battery < 30;

    return CardShell(
      color: color,
      glowAnim: glowAnim,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CardLabel(
                  text: 'BATTERY LEVEL',
                  icon: Icons.battery_charging_full_rounded,
                  color: color,
                ),
                const Spacer(),
                if (warn) _LowBatteryWarning(pulseAnim: pulseAnim),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${battery.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                _SegmentedBattery(fraction: battery / 100, color: color),
              ],
            ),
            const SizedBox(height: 10),
            _BatteryBar(fraction: battery / 100, color: color),
          ],
        ),
      ),
    );
  }
}

class _LowBatteryWarning extends StatelessWidget {
  final Animation<double> pulseAnim;

  const _LowBatteryWarning({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => Opacity(
        opacity: pulseAnim.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.red, width: 1),
          ),
          child: const Text(
            '⚠ LOW',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentedBattery extends StatelessWidget {
  final double fraction;
  final Color color;

  const _SegmentedBattery({
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const int total = 10;
    final int filled = (fraction * total).round();

    return Row(
      children: List.generate(total, (i) {
        final bool on = i < filled;
        return Container(
          width: 10,
          height: 22,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: on ? color.withOpacity(0.8) : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withOpacity(0.2), width: 0.5),
            boxShadow: on
                ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)]
                : [],
          ),
        );
      }),
    );
  }
}

class _BatteryBar extends StatelessWidget {
  final double fraction;
  final Color color;

  const _BatteryBar({
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
            ),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
            ],
          ),
        ),
      ),
    );
  }
}