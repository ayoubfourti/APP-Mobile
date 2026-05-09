import 'package:flutter/material.dart';

class JoystickWidget extends StatefulWidget {
  final void Function(double dx, double dy)? onMove;
  final VoidCallback? onRelease;

  const JoystickWidget({super.key, this.onMove, this.onRelease});

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  Offset _joystickPosition = Offset.zero;
  final double _maxDistance = 70;

  void _updatePosition(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    Offset offset = localPosition - center;
    if (offset.distance > _maxDistance) {
      offset = Offset.fromDirection(offset.direction, _maxDistance);
    }
    setState(() => _joystickPosition = offset);

    // Normalise -1.0 → 1.0 et envoie au ControlState
    widget.onMove?.call(
      offset.dx / _maxDistance,
      offset.dy / _maxDistance,
    );
  }

  void _resetPosition() {
    setState(() => _joystickPosition = Offset.zero);
    widget.onRelease?.call();
  }

  @override
  Widget build(BuildContext context) {
    // UI identique à l'original
    return GestureDetector(
      onPanUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        _updatePosition(box.globalToLocal(details.globalPosition), box.size);
      },
      onPanEnd: (_) => _resetPosition(),
      onPanCancel: _resetPosition,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1E2A47),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(top: 20,
                child: Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 30)),
            const Positioned(left: 20,
                child: Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 30)),
            const Positioned(right: 20,
                child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30)),
            const Positioned(bottom: 20,
                child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30)),
            Transform.translate(
              offset: _joystickPosition,
              child: const CircleAvatar(radius: 50, backgroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}