import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.navyBlue.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyan.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            Icons.wifi_rounded,
            'CONNECTED',
            AppColors.green,
          ),
          _buildDivider(),
          _buildStatusItem(
            Icons.sensors_rounded,
            '6 ACTIVE',
            AppColors.cyan,
          ),
          _buildDivider(),
          _buildStatusItem(
            Icons.speed_rounded,
            'REAL-TIME',
            AppColors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20,
      color: AppColors.cyan.withOpacity(0.2),
    );
  }
}
