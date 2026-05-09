// lib/features/robot_control/presentation/widgets/mini_map_widget.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../../core/services/slam_map_service.dart';

class MiniMapWidget extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const MiniMapWidget({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E27).withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00F5FF).withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F5FF).withOpacity(0.2),
              blurRadius: 12,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Map SLAM en temps réel
              Positioned.fill(
                child: ListenableBuilder(
                  listenable: SlamMapService.instance,
                  builder: (context, _) {
                    final map = SlamMapService.instance.currentMap;
                    if (map == null) return _buildFallback();
                    return CustomPaint(
                      painter: _SlamMapPainter(map),
                    );
                  },
                ),
              ),

              // Label "SLAM MAP"
              Positioned(
                top: 6,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "SLAM",
                    style: TextStyle(
                      color: const Color(0xFF00F5FF).withOpacity(0.9),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              // Icône expand
              Positioned(
                bottom: 6,
                right: 6,
                child: Icon(
                  Icons.open_in_full_rounded,
                  color: const Color(0xFF00F5FF).withOpacity(0.7),
                  size: 12,
                ),
              ),

              // Indicateur de connexion
              Positioned(
                top: 6,
                right: 8,
                child: ListenableBuilder(
                  listenable: SlamMapService.instance,
                  builder: (context, _) {
                    final connected = SlamMapService.instance.isConnected;
                    final hasMap = SlamMapService.instance.currentMap != null;
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasMap
                            ? const Color(0xFF00FF00)
                            : connected
                                ? const Color(0xFFFFAA00)
                                : const Color(0xFFFF0000),
                        boxShadow: [
                          BoxShadow(
                            color: (hasMap
                                    ? const Color(0xFF00FF00)
                                    : const Color(0xFFFF0000))
                                .withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFF0D1B2A),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, color: Color(0xFF00F5FF), size: 32),
            SizedBox(height: 4),
            Text(
              "MAPPING...",
              style: TextStyle(
                color: Color(0xFF00F5FF),
                fontSize: 8,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlamMapPainter extends CustomPainter {
  final ui.Image map;
  _SlamMapPainter(this.map);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / map.width;
    final scaleY = size.height / map.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - map.width * scale) / 2;
    final offsetY = (size.height - map.height * scale) / 2;

    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);
    canvas.drawImage(map, Offset.zero, Paint()..filterQuality = FilterQuality.low);

    // Point du robot (centre de la map pour l'instant)
    final robotPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(map.width / 2, map.height / 2),
      4 / scale,
      robotPaint,
    );

    // Cercle autour du robot
    final ringPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / scale;
    canvas.drawCircle(
      Offset(map.width / 2, map.height / 2),
      8 / scale,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SlamMapPainter old) => old.map != map;
}