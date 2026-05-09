import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/animations/mixins/tech_animations_mixin.dart';
import '../../../../core/widgets/backgrounds/animated_tech_background.dart';
import '../state/control_state.dart';
import '../widgets/camera_section.dart';
import '../widgets/joystick_section.dart';
import '../widgets/auto_mode_button.dart';
import '../../../mission/data/mission_log_service.dart';
import '../../../../core/services/slam_map_service.dart';
import '../../../../core/config/api_config.dart';

class ControlRobotPage extends StatelessWidget {
  final String? cameraStreamUrl;

  ControlRobotPage({
    super.key,
    String? cameraStreamUrl,
  }) : cameraStreamUrl = cameraStreamUrl ?? ApiConfig.cameraStreamUrl;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ControlState(),
      child: _ControlRobotView(cameraStreamUrl: cameraStreamUrl),
    );
  }
}

class _ControlRobotView extends StatefulWidget {
  final String? cameraStreamUrl;
  const _ControlRobotView({this.cameraStreamUrl});

  @override
  State<_ControlRobotView> createState() => _ControlRobotViewState();
}

class _ControlRobotViewState extends State<_ControlRobotView>
    with TickerProviderStateMixin, TechAnimationsMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isAutoMode = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    initializeTechAnimations();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  void _startAnimations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fadeController.forward();
      startTechAnimations();
      context.read<ControlState>().refreshConnection();
      MissionLogService.instance.start();
      SlamMapService.instance.connect();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    disposeTechAnimations();
    MissionLogService.instance.stop();
    SlamMapService.instance.disconnect();
    super.dispose();
  }

  void _toggleAutoMode() {
    context.read<ControlState>().toggleAutoMode();
    setState(() => _isAutoMode = !_isAutoMode);
    _showAutoModeSnackBar();
  }

  void _showAutoModeSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF00F5FF), width: 1),
        ),
        content: Row(
          children: [
            Icon(
              _isAutoMode ? Icons.check_circle : Icons.cancel,
              color: _isAutoMode
                  ? const Color(0xFF00FF00)
                  : const Color(0xFFFF6B6B),
            ),
            const SizedBox(width: 12),
            Text(
              _isAutoMode ? "Auto mode activated" : "Manual control enabled",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: AnimatedBuilder(
        animation: particleController,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
                return const SizedBox.expand();
              }
              return AnimatedTechBackground(
                particleAnimation: particleController.value,
                rotateAnimation: 0,
                child: _buildContent(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Column(
            children: [
              Expanded(
                flex: 75,
                child: CameraSection(streamUrl: widget.cameraStreamUrl),
              ),
              const SizedBox(height: 8),
              const Expanded(
                flex: 22,
                child: JoystickSection(),
              ),
              const SizedBox(height: 6),
              AutoModeButton(
                isAutoMode: _isAutoMode,
                glowController: glowController,
                onToggle: _toggleAutoMode,
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}