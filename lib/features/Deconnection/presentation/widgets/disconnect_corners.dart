import 'package:flutter/material.dart';
import '../../disconnect_constants.dart';
import '../painters/corner_painter.dart';

/// Renders the four HUD bracket corners as a list of [Positioned] widgets.
/// Wrap with a [Stack] that uses [StackFit.expand].
class DisconnectCorners extends StatelessWidget {
  const DisconnectCorners({super.key});

  static const double _size = 36.0;
  static const double _pad = 24.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < 4; i++)
          Positioned(
            left:   i.isEven ? _pad : null,
            right:  i.isEven ? null : _pad,
            top:    i < 2   ? _pad : null,
            bottom: i < 2   ? null : _pad,
            child: CustomPaint(
              size: const Size(_size, _size),
              painter: CornerPainter(
                isLeft: i.isEven,
                isTop:  i < 2,
                color:  DisconnectConstants.red,
              ),
            ),
          ),
      ],
    );
  }
}