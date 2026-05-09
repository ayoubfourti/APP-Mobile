import 'package:flutter/material.dart';
import '../../../../core/animations/mixins/tech_animations_mixin.dart';
import '../../../../core/widgets/backgrounds/animated_tech_background.dart';
import '../widgets/header_widget.dart';
import '../widgets/status_card.dart';
import '../widgets/tools_grid.dart';
import '../../data/tool_items_data.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage>
    with TickerProviderStateMixin, TechAnimationsMixin {
  late AnimationController _fadeController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // ✅ Initialise les animations du mixin
    initializeTechAnimations();

    // Animations spécifiques à cette page
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Démarre toutes les animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        _cardController.forward();
        startTechAnimations(); // ✅ Du mixin
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _cardController.dispose();
    disposeTechAnimations(); // ✅ Du mixin
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([particleController, rotateController]),
        builder: (context, _) {
          return AnimatedTechBackground(
            particleAnimation: particleController.value,
            rotateAnimation: rotateAnimation.value,
            child: _buildContent(),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // Header avec logo animé
              HeaderWidget(
                glowController: glowController,
                rotateController: rotateController,
                rotateAnimation: rotateAnimation,
              ),
              
              const SizedBox(height: 25),
              
              // Carte de statut de connexion
              StatusCard(glowController: glowController),
              
              const SizedBox(height: 25),
              
              // Grid des outils
              Expanded(
                child: ToolsGrid(
                  tools: ToolItemsData.getTools(context),
                  cardController: _cardController,
                  glowController: glowController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}