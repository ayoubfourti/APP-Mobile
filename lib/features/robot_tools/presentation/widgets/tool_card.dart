import 'package:flutter/material.dart';
import '../../../../core/widgets/painters/hexagon_painter.dart';
class ToolCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDanger;
  final AnimationController glowController;

  const ToolCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isDanger = false,
    required this.glowController,
  });

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isDanger
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF00F5FF);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _hoverController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _hoverController.reverse();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withOpacity(0.6),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _isPressed
                      ? accentColor
                      : accentColor.withOpacity(0.3),
                  width: _isPressed ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? accentColor.withOpacity(0.4)
                        : accentColor.withOpacity(0.1),
                    blurRadius: _isPressed ? 30 : 20,
                    spreadRadius: _isPressed ? 5 : 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Hexagone décoratif en arrière-plan
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        size: const Size(80, 80),
                        painter: HexagonPainter(color: accentColor),
                      ),
                    ),
                  ),

                  // Contenu
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône avec animation de pulsation
                      AnimatedBuilder(
                        animation: widget.glowController,
                        builder: (context, child) {
                          final glowValue = widget.glowController.value.clamp(
                            0.0,
                            1.0,
                          );
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(
                                    glowValue * 0.3,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              size: 45,
                              color: accentColor,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      // Titre
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 1.2,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: accentColor.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Indicateur de disponibilité
                      if (widget.onTap != null)
                        Container(
                          width: 30,
                          height: 3,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
