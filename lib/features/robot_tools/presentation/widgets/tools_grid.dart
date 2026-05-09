// lib/features/robot_tools/presentation/widgets/tools_grid.dart

import 'package:flutter/material.dart';
import '../models/tool_item.dart';
import 'tool_card.dart';

/// ✅ StatefulWidget — animations créées UNE SEULE FOIS dans initState
/// Avant : CurvedAnimation recréé à chaque frame → crash _elements.contains
class ToolsGrid extends StatefulWidget {
  final List<ToolItem> tools;
  final AnimationController cardController;
  final AnimationController glowController;

  const ToolsGrid({
    super.key,
    required this.tools,
    required this.cardController,
    required this.glowController,
  });

  @override
  State<ToolsGrid> createState() => _ToolsGridState();
}

class _ToolsGridState extends State<ToolsGrid> {
  // ✅ Animations pré-créées une seule fois
  late final List<Animation<double>> _animations;
  late final List<CurvedAnimation> _curvedAnimations;

  @override
  void initState() {
    super.initState();
    _curvedAnimations = [];
    _animations = [];

    for (int i = 0; i < widget.tools.length; i++) {
      final delay = i * 0.1;
      final curved = CurvedAnimation(
        parent: widget.cardController,
        curve: Interval(
          delay.clamp(0.0, 1.0),
          (delay + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOutBack,
        ),
      );
      _curvedAnimations.add(curved);
      _animations.add(Tween<double>(begin: 0, end: 1).animate(curved));
    }
  }

  @override
  void dispose() {
    // ✅ Dispose proprement chaque CurvedAnimation
    for (final ca in _curvedAnimations) {
      ca.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.tools.length,
      itemBuilder: (context, index) {
        return _buildAnimatedToolCard(widget.tools[index], index);
      },
    );
  }

  Widget _buildAnimatedToolCard(ToolItem tool, int index) {
    // ✅ Utilise l'animation pré-créée — pas de new CurvedAnimation ici
    final animation = _animations[index];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      // ✅ child en dehors du builder = pas reconstruit à chaque frame
      child: ToolCard(
        icon: tool.icon,
        title: tool.title,
        onTap: tool.isEnabled ? tool.onTap : null,
        isDanger: tool.isDanger,
        glowController: widget.glowController,
      ),
    );
  }
}