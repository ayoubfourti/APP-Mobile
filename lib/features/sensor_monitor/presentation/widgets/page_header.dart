import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PageHeader extends StatelessWidget {
  final Animation<double>? glowAnim; // ✅ Rendre nullable

  const PageHeader({
    super.key,
    this.glowAnim, // ✅ Optionnel
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Bouton retour
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.cyan,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Titre
          Expanded(
            child: glowAnim != null
                ? AnimatedBuilder(
                    animation: glowAnim!,
                    builder: (context, child) => Text(
                      'SENSOR MONITOR',
                      style: TextStyle(
                        color: AppColors.cyan.withOpacity(
                          0.7 + glowAnim!.value * 0.3,
                        ),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  )
                : const Text(
                    'SENSOR MONITOR',
                    style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
          ),

          // Indicateur
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.green.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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
