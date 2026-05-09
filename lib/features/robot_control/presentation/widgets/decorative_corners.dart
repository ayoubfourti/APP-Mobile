import 'package:flutter/material.dart';

/// Coins décoratifs pour la section caméra
class DecorativeCorners extends StatelessWidget {
  const DecorativeCorners({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Corner(top: 12, left: 12, showTop: true, showLeft: true),
        _Corner(top: 12, right: 12, showTop: true, showRight: true),
        _Corner(bottom: 12, left: 12, showBottom: true, showLeft: true),
        _Corner(bottom: 12, right: 12, showBottom: true, showRight: true),
      ],
    );
  }
}

/// Widget pour un coin individuel
class _Corner extends StatelessWidget {
  final double? top;
  final double? left;
  final double? bottom;
  final double? right;
  final bool showTop;
  final bool showLeft;
  final bool showBottom;
  final bool showRight;

  const _Corner({
    this.top,
    this.left,
    this.bottom,
    this.right,
    this.showTop = false,
    this.showLeft = false,
    this.showBottom = false,
    this.showRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: showTop
                ? BorderSide(
                    color: const Color(0xFF00F5FF).withOpacity(0.6),
                    width: 2,
                  )
                : BorderSide.none,
            left: showLeft
                ? BorderSide(
                    color: const Color(0xFF00F5FF).withOpacity(0.6),
                    width: 2,
                  )
                : BorderSide.none,
            bottom: showBottom
                ? BorderSide(
                    color: const Color(0xFF00F5FF).withOpacity(0.6),
                    width: 2,
                  )
                : BorderSide.none,
            right: showRight
                ? BorderSide(
                    color: const Color(0xFF00F5FF).withOpacity(0.6),
                    width: 2,
                  )
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}