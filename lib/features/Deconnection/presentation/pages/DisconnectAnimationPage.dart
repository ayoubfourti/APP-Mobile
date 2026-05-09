import 'package:flutter/material.dart';
import '../../../robot_connection/presentation/pages/connect_robot_page.dart';
import '../controllers/disconnect_controller.dart';
import '../painters/red_grid_painter.dart';
import '../painters/hex_rings_painter.dart';
import '../painters/scan_line_painter.dart';
import '../painters/particle_painter.dart';
import '../widgets/disconnect_background.dart';
import '../widgets/disconnect_power_icon.dart';
import '../widgets/disconnect_title.dart';
import '../widgets/disconnect_status_line.dart';
import '../widgets/disconnect_progress_bar.dart';
import '../widgets/disconnect_step_indicators.dart';
import '../widgets/disconnect_data_strip.dart';
import '../widgets/disconnect_corners.dart';
import '../../disconnect_constants.dart';

class DisconnectAnimationPage extends StatefulWidget {
  const DisconnectAnimationPage({super.key});
  @override
  State<DisconnectAnimationPage> createState() => _DisconnectAnimationPageState();
}

class _DisconnectAnimationPageState extends State<DisconnectAnimationPage>
    with TickerProviderStateMixin {

  late final DisconnectController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = DisconnectController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ctrl.startAll();
      _ctrl.runSequence(isMounted: () => mounted).then((_) async {
        await Future.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, _exitRoute(), (_) => false);
      });
    });
  }

  PageRouteBuilder _exitRoute() => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => const ConnectRobotPage(),
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn), child: child),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: DisconnectConstants.bg,
      body: AnimatedBuilder(
        animation: _ctrl.master,
        builder: (_, __) {
          final opacity = _ctrl.messageIndex.value >= DisconnectConstants.messages.length - 1
              ? _ctrl.fadeOut.value.clamp(0.0, 1.0)
              : _ctrl.fadeIn.value.clamp(0.0, 1.0);

          return Opacity(
            opacity: opacity,
            child: Stack(fit: StackFit.expand, children: [
              const DisconnectBackground(),
              CustomPaint(painter: RedGridPainter()),
              AnimatedBuilder(
                animation: _ctrl.rotate,
                builder: (_, __) => CustomPaint(
                  painter: HexRingsPainter(
                    rotation: _ctrl.rotate.value * 2 * 3.14159,
                    progress: _ctrl.progress.value,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _ctrl.scan,
                builder: (_, __) => CustomPaint(
                  painter: ScanLinePainter(t: _ctrl.scan.value, size: size),
                ),
              ),
              AnimatedBuilder(
                animation: _ctrl.scan,
                builder: (_, __) => CustomPaint(
                  painter: ParticlePainter(t: _ctrl.scan.value, size: size),
                ),
              ),
              DisconnectCorners(),
              Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  DisconnectPowerIcon(pulse: _ctrl.pulse),
                  const SizedBox(height: 36),
                  ValueListenableBuilder(
                    valueListenable: _ctrl.glitchState,
                    builder: (_, g, __) => DisconnectTitle(
                      showGlitch: g.show, dx: g.dx, dy: g.dy),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: _ctrl.messageIndex,
                    builder: (_, i, __) => DisconnectStatusLine(
                      text: DisconnectConstants.messages[i]),
                  ),
                  const SizedBox(height: 48),
                  DisconnectProgressBar(progress: _ctrl.progress),
                  const SizedBox(height: 20),
                  DisconnectStepIndicators(progress: _ctrl.progress),
                ]),
              ),
              const Positioned(
                left: 0, right: 0, bottom: 40,
                child: DisconnectDataStrip(),
              ),
            ]),
          );
        },
      ),
    );
  }
}