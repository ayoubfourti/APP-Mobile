import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../disconnect_constants.dart';

class DisconnectController {
  DisconnectController({required TickerProvider vsync}) {
    master = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800), // ← était 1300
    );
    pulse = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 700),
    );
    scan = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    );
    rotate = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 8),
    );
    glitch = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 40),
    ); // ← était 80

    fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: master,
        curve: const Interval(0.0, 0.12, curve: Curves.easeIn),
      ),
    );
    progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: master,
        curve: const Interval(0.10, 0.88, curve: Curves.easeInOut),
      ),
    );
    fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: master,
        curve: const Interval(0.88, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  // ── Controllers ────────────────────────────────
  late final AnimationController master;
  late final AnimationController pulse;
  late final AnimationController scan;
  late final AnimationController rotate;
  late final AnimationController glitch;

  // ── Animations ─────────────────────────────────
  late final Animation<double> fadeIn;
  late final Animation<double> progress;
  late final Animation<double> fadeOut;

  // ── Glitch state ───────────────────────────────
  final ValueNotifier<({bool show, double dx, double dy})> glitchState =
      ValueNotifier((show: false, dx: 0, dy: 0));

  // ── Message state ──────────────────────────────
  final ValueNotifier<int> messageIndex = ValueNotifier(0);

  void startAll() {
    master.forward();
    pulse.repeat(reverse: true);
    scan.repeat();
    rotate.repeat();
  }

  Future<void> runSequence({required bool Function() isMounted}) async {
    for (int i = 0; i < DisconnectConstants.messages.length; i++) {
      // ← était 100 + i * 160 (~3.9s total) → 50 + i * 80 (~1.85s total)
      await Future.delayed(Duration(milliseconds: 50 + i * 80));
      if (!isMounted()) return;
      await _triggerGlitch(isMounted: isMounted);
      if (!isMounted()) return;
      messageIndex.value = i;
    }

    // ← était 250ms
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _triggerGlitch({required bool Function() isMounted}) async {
    final rng = math.Random();
    // ← était 5 itérations × (20ms + 10ms) = 150ms → 3 × (10ms + 5ms) = 45ms
    for (int i = 0; i < 3; i++) {
      if (!isMounted()) return;
      glitchState.value = (
        show: true,
        dx: rng.nextDouble() * 24 - 12,
        dy: rng.nextDouble() * 6 - 3,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      if (!isMounted()) return;
      glitchState.value = (show: false, dx: 0, dy: 0);
      await Future.delayed(const Duration(milliseconds: 5));
    }
  }

  void dispose() {
    master.dispose();
    pulse.dispose();
    scan.dispose();
    rotate.dispose();
    glitch.dispose();
    glitchState.dispose();
    messageIndex.dispose();
  }
}
