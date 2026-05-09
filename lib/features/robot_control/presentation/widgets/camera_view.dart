import 'package:flutter/material.dart';
import 'mini_map_widget.dart';
import 'dart:ui' as ui;
import '../../../../core/services/slam_map_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import '../../../../core/services/rosbridge_service.dart';
import '../../../../core/services/notification_service.dart';


class CameraView extends StatefulWidget {
  final String? imagePath;

  const CameraView({
    super.key,
    this.imagePath,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with SingleTickerProviderStateMixin {
  bool _mapExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

    bool _gasDetected = false;
  StreamSubscription? _gasSub;

 @override
void initState() {
  super.initState();
  _expandController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  _expandAnimation = CurvedAnimation(
    parent: _expandController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  // 👇 AJOUTE ÇA
  _gasSub = RosbridgeService().messages.listen((message) {
  try {
    final data = jsonDecode(message);
    if (data['type'] == 'gaz') {
      final bool newAlert = data['alert'] == true;

      // 👇 Notif seulement au moment où le gaz est détecté (front montant)
      if (newAlert && !_gasDetected) {
        NotificationService.instance.showGasAlert();
      }

      setState(() => _gasDetected = newAlert);
    }
  } catch (_) {}
});
}

  @override
void dispose() {
  _gasSub?.cancel(); // 👈 AJOUTE ÇA
  _expandController.dispose();
  super.dispose();
}

  void _toggleMap() {
    setState(() => _mapExpanded = !_mapExpanded);
    if (_mapExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _closeMap() {
    if (_mapExpanded) _toggleMap();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(),
        _buildGridOverlay(),

    

        Positioned(
          top: 12, right: 12,
          child: MiniMapWidget(
            isExpanded: _mapExpanded,
            onTap: _toggleMap,
          ),
        ),

        Positioned(
          bottom: 12, left: 12,
          child: _buildBatteryBadge(),
        ),

        Positioned(
          bottom: 12, right: 12,
          child: _buildGasIndicatorBadge(),
        ),

        if (_mapExpanded || _expandController.isAnimating)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMap,
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, _) {
                  return Container(
                    color: Colors.black.withOpacity(0.5 * _expandAnimation.value),
                    child: Center(
                      child: Transform.scale(
                        scale: 0.6 + 0.4 * _expandAnimation.value,
                        child: Opacity(
                          opacity: _expandAnimation.value,
                          child: GestureDetector(
                            onTap: () {},
                            child: _buildExpandedMap(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      if (widget.imagePath!.startsWith('http')) {
        return _MjpegView(url: widget.imagePath!);
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildExpandedMap() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E27),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: ListenableBuilder(
                listenable: SlamMapService.instance,
                builder: (context, _) {
                  final map = SlamMapService.instance.currentMap;
                  if (map == null) {
                    return Container(
                      color: const Color(0xFF0D1B2A),
                      child: Center(
                        child: Icon(Icons.map_outlined,
                            color: const Color(0xFF00F5FF).withOpacity(0.4),
                            size: 64),
                      ),
                    );
                  }
                  return CustomPaint(
                    painter: _ExpandedSlamPainter(map),
                  );
                },
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_rounded,
                        color: Color(0xFF00F5FF), size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      "SLAM MAP",
                      style: TextStyle(
                        color: Color(0xFF00F5FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _closeMap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF00F5FF).withOpacity(0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF00F5FF),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    "TAP OUTSIDE TO CLOSE",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.battery_full_rounded, color: Color(0xFF00FF88), size: 16),
          SizedBox(width: 4),
          Text(
            "-- %",
            style: TextStyle(
              color: Color(0xFF00FF88),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF0A0E27),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F5FF).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFF00F5FF).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 64, color: Color(0xFF00F5FF)),
            ),
            const SizedBox(height: 20),
            const Text(
              "CAMERA PREVIEW",
              style: TextStyle(
                color: Color(0xFF00F5FF), fontSize: 16,
                fontWeight: FontWeight.w700, letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Image placeholder for UI development",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.1), width: 1,
        ),
      ),
      child: CustomPaint(painter: _CameraGridPainter()),
    );
  }

  Widget _buildCameraBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_rounded, color: Color(0xFF00F5FF), size: 14),
          SizedBox(width: 6),
          Text(
            "CAM 01",
            style: TextStyle(color: Colors.white, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildGasIndicatorBadge() {
  final color = _gasDetected ? const Color(0xFFFF3D3D) : const Color(0xFF00FF00);
  final label = _gasDetected ? 'GAZ DÉTECTÉ' : 'AIR NORMALE';
  final icon = _gasDetected ? Icons.warning_amber_rounded : Icons.air_rounded;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.6),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dot animé
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    ),
  );
}
}

// ─── MJPEG Player ─────────────────────────────────────────────────────────────

class _MjpegView extends StatefulWidget {
  final String url;
  const _MjpegView({required this.url});

  @override
  State<_MjpegView> createState() => _MjpegViewState();
}

class _MjpegViewState extends State<_MjpegView> {
  Uint8List? _currentFrame;
  HttpClient? _client;
  HttpClientResponse? _response;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  void _startStream() async {
    try {
      _client = HttpClient();
      _client!.idleTimeout = const Duration(seconds: 5);
      final request = await _client!.getUrl(Uri.parse(widget.url));
      _response = await request.close();

      List<int> buffer = [];

      _response!.listen(
        (data) {
          if (_disposed) return;
          buffer.addAll(data);

          while (true) {
            final start = _findJpegStart(buffer);
            if (start == -1) break;
            final end = _findJpegEnd(buffer, start);
            if (end == -1) break;
            final frame = Uint8List.fromList(buffer.sublist(start, end + 2));
            if (mounted && !_disposed) {
              setState(() => _currentFrame = frame);
            }
            buffer = buffer.sublist(end + 2);
          }
        },
        onError: (e) {
          if (!_disposed) debugPrint('MJPEG error: $e');
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (!_disposed) debugPrint('MJPEG error: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _response?.detachSocket().then((socket) => socket.destroy());
    _client?.close(force: true);
    super.dispose();
  }

  int _findJpegStart(List<int> data) {
    for (int i = 0; i < data.length - 1; i++) {
      if (data[i] == 0xFF && data[i + 1] == 0xD8) return i;
    }
    return -1;
  }

  int _findJpegEnd(List<int> data, int start) {
    for (int i = start + 2; i < data.length - 1; i++) {
      if (data[i] == 0xFF && data[i + 1] == 0xD9) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentFrame == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00F5FF)),
      );
    }
    return Image.memory(
      _currentFrame!,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.08)
      ..strokeWidth = 1;

    final tw = size.width / 3;
    final th = size.height / 3;

    canvas.drawLine(Offset(tw, 0),     Offset(tw, size.height),     paint);
    canvas.drawLine(Offset(tw * 2, 0), Offset(tw * 2, size.height), paint);
    canvas.drawLine(Offset(0, th),     Offset(size.width, th),      paint);
    canvas.drawLine(Offset(0, th * 2), Offset(size.width, th * 2),  paint);

    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _ExpandedSlamPainter extends CustomPainter {
  final ui.Image map;
  _ExpandedSlamPainter(this.map);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / map.width;
    final scaleY = size.height / map.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - map.width * scale) / 2;
    final offsetY = (size.height - map.height * scale) / 2;

    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);
    canvas.drawImage(map, Offset.zero, Paint()..filterQuality = FilterQuality.none);

    final robotPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(map.width / 2, map.height / 2),
      3 / scale,
      robotPaint,
    );

    final ringPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / scale;
    canvas.drawCircle(
      Offset(map.width / 2, map.height / 2),
      6 / scale,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ExpandedSlamPainter old) => old.map != map;
}