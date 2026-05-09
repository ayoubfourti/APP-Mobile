import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Mixin qui fournit toutes les animations "tech/cyber" communes
mixin TechAnimationsMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController pulseController;
  late final AnimationController rotateController;
  late final AnimationController particleController;
  late final AnimationController scanController;
  late final AnimationController glowController;
  
  late final Animation<double> pulseAnimation;
  late final Animation<double> rotateAnimation;

  /// Initialise toutes les animations communes
  void initializeTechAnimations() {
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(rotateController);

    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  /// Démarre toutes les animations en boucle
  void startTechAnimations() {
    if (!mounted) return;
    pulseController.repeat(reverse: true);
    rotateController.repeat();
    particleController.repeat();
    scanController.repeat();
    glowController.repeat(reverse: true);
  }

  /// Dispose toutes les animations
  void disposeTechAnimations() {
    pulseController.dispose();
    rotateController.dispose();
    particleController.dispose();
    scanController.dispose();
    glowController.dispose();
  }
}