import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Mixin pour les animations spécifiques aux capteurs
mixin SensorAnimationsMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController radarController;
  late final AnimationController batteryPulseController;
  late final AnimationController cameraBlinkController;
  late final AnimationController entryController;

  late final Animation<double> radarAnimation;
  late final Animation<double> batteryPulseAnimation;
  late final Animation<double> cameraBlinkAnimation;
  late final Animation<double> entryAnimation;

  /// Initialise toutes les animations spécifiques aux capteurs
  void initializeSensorAnimations() {
    // Radar (rotation continue)
    radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    radarAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(radarController);

    // Pulse (batterie)
    batteryPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    batteryPulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: batteryPulseController, curve: Curves.easeInOut),
    );

    // Blink caméra
    cameraBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    cameraBlinkAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: cameraBlinkController, curve: Curves.easeInOut),
    );

    // Entrée de page
    entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    entryAnimation = CurvedAnimation(
      parent: entryController,
      curve: Curves.easeOutCubic,
    );
  }

  /// Démarre toutes les animations
  void startSensorAnimations() {
    if (!mounted) return;
    radarController.repeat();
    batteryPulseController.repeat(reverse: true);
    cameraBlinkController.repeat(reverse: true);

    // Animation d'entrée (une seule fois)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) entryController.forward();
    });
  }

  /// Dispose toutes les animations
  void disposeSensorAnimations() {
    radarController.dispose();
    batteryPulseController.dispose();
    cameraBlinkController.dispose();
    entryController.dispose();
  }
}
