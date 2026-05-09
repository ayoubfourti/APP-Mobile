import 'package:flutter/material.dart';
import '../../../../../../../core/animations/mixins/tech_animations_mixin.dart';
import '../../../../core/widgets/backgrounds/animated_tech_background.dart';
import '../widgets/animated_robot_icon.dart';
import '../widgets/scan_line.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/connect_button.dart';
import '../widgets/connecting_overlay.dart';
import '../widgets/footer_widget.dart';
import '../../../robot_tools/presentation/pages/tools_page.dart';
import '../../data/robot_repository.dart'; // ✅
import '../../data/robot_session.dart';    // ✅

class ConnectRobotPage extends StatefulWidget {
  const ConnectRobotPage({super.key});

  @override
  State<ConnectRobotPage> createState() => _ConnectRobotPageState();
}

class _ConnectRobotPageState extends State<ConnectRobotPage>
    with TickerProviderStateMixin, TechAnimationsMixin {
  final ipController   = TextEditingController();
  final portController = TextEditingController();
  bool _isConnecting   = false;

  @override
  void initState() {
    super.initState();
    initializeTechAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTechAnimations();
    });
  }

  Future<void> _connectToRobot() async {
    if (ipController.text.isEmpty || portController.text.isEmpty) {
      _showErrorSnackBar("Veuillez entrer l'IP et le Port");
      return;
    }

    final port = int.tryParse(portController.text.trim());
    if (port == null) {
      _showErrorSnackBar("Port invalide");
      return;
    }

    setState(() => _isConnecting = true);

    // ✅ Vérifier si le robot existe en BD
    final result = await RobotRepository.findByIpPort(
      ip:   ipController.text.trim(),
      port: port,
    );

    if (!mounted) return;

    if (!result.ok) {
      // ❌ Robot non trouvé
      setState(() => _isConnecting = false);
      _showErrorSnackBar(result.error ?? 'Robot introuvable');
      return;
    }

    // ✅ Robot trouvé — stocker dans singleton
    final robot = result.data!;
    RobotSession.instance.set(
  id:   int.parse(robot['id_robot'].toString()),   // ✅ snake_case = clé réelle BD
  name: robot['name_robot'] as String,              // ✅ snake_case = clé réelle BD
  ip:   ipController.text.trim(),
  port: port,
);

    // ✅ Naviguer vers ToolsPage
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, animation, __) => const ToolsPage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFF00F5FF), width: 1),
        ),
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
            const SizedBox(width: 10),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    disposeTechAnimations();
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([particleController, rotateController]),
        builder: (context, _) => AnimatedTechBackground(
          particleAnimation: particleController.value,
          rotateAnimation: rotateAnimation.value,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          AnimatedRobotIcon(
                            pulseAnimation: pulseAnimation,
                            rotateAnimation: rotateAnimation,
                          ),
                          const SizedBox(height: 30),
                          _buildAnimatedTitle(),
                          const Text(
                            "RESCUE ROBOT",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 6,
                              color: Color(0xFF00F5FF),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ScanLine(scanController: scanController),
                          const SizedBox(height: 10),
                          _buildSecurePortalBadge(),
                          const SizedBox(height: 40),
                          GlassTextField(
                            controller: ipController,
                            label: "ROBOT IP ADDRESS",
                            icon: Icons.lan_rounded,
                            hint: "192.168.1.100",
                          ),
                          const SizedBox(height: 20),
                          GlassTextField(
                            controller: portController,
                            label: "CONNECTION PORT",
                            icon: Icons.settings_input_antenna_rounded,
                            hint: "8080",
                            isNumber: true,
                          ),
                          const SizedBox(height: 40),
                          ConnectButton(
                            isConnecting: _isConnecting,
                            onTap: _connectToRobot,
                          ),
                          const SizedBox(height: 30),
                          const FooterWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isConnecting) const ConnectingOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: const [
            Color(0xFF00F5FF),
            Color(0xFF00D9FF),
            Color(0xFF00F5FF),
          ],
          stops: [0.0, glowController.value, 1.0],
        ).createShader(bounds),
        child: const Text(
          "HEXAPOD",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: Colors.white,
            shadows: [
              Shadow(color: Color(0xFF00F5FF), blurRadius: 20),
              Shadow(color: Color(0xFF00F5FF), blurRadius: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurePortalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00F5FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
        ),
      ),
      child: const Text(
        "⚡ SECURE CONNECTION PORTAL ⚡",
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF00F5FF),
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}