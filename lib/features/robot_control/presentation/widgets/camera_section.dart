import 'package:flutter/material.dart';
import 'camera_view.dart';
import 'decorative_corners.dart';

/// Section caméra avec bordure et coins décoratifs
class CameraSection extends StatelessWidget {
  final String? streamUrl; // ✅ Ajout du paramètre

  const CameraSection({
    super.key,
    this.streamUrl, // ✅ Paramètre optionnel
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Vue caméra
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0A0E27),
                child: CameraView(
                  imagePath: streamUrl, // ✅ Passe l'URL à CameraView
                ),
              ),
            ),
            
            // Coins décoratifs
            const DecorativeCorners(),
          ],
        ),
      ),
    );
  }
}