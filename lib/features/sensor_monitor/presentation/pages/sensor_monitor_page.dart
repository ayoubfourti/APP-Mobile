import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/animations/mixins/tech_animations_mixin.dart';
import '../../../../core/theme/app_colors.dart';
import '../state/sensor_state.dart';
import '../controllers/sensor_animations_mixin.dart';
import '../widgets/animated_background.dart';
import '../widgets/page_header.dart';
import '../widgets/status_bar.dart';
import '../widgets/sensor_grid.dart';

class SensorMonitorPage extends StatefulWidget {
  const SensorMonitorPage({super.key});

  @override
  State<SensorMonitorPage> createState() => _SensorMonitorPageState();
}

class _SensorMonitorPageState extends State<SensorMonitorPage>
    with TickerProviderStateMixin, TechAnimationsMixin, SensorAnimationsMixin {

  @override
  void initState() {
    super.initState();
    initializeTechAnimations();
    initializeSensorAnimations();
    startTechAnimations();
    startSensorAnimations();
  }

  @override
  void dispose() {
    disposeTechAnimations();
    disposeSensorAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      // ✅ .value — on réutilise le singleton, on ne le recrée pas
      value: SensorState.instance,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([rotateController, particleController]),
              builder: (context, _) => AnimatedBackground(
                bgRotateAnim: rotateAnimation,
                bgParticleController: particleController,
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: entryAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(entryAnimation),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: PageHeader(glowAnim: glowController.view),
                      ),
                      const SliverToBoxAdapter(child: StatusBar()),
                      Consumer<SensorState>(
                        builder: (context, sensorState, _) {
                          return SensorGrid(
                            data:             sensorState.currentData,
                            radarAnim:        radarAnimation,
                            pulseAnim:        batteryPulseAnimation,
                            cameraBlinkAnim:  cameraBlinkAnimation,
                            glowAnim:         glowController.view,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}