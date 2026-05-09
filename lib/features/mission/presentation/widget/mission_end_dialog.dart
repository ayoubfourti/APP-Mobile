// lib/features/mission/presentation/widgets/mission_end_dialog.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mission_model.dart';
import '../../data/mission_state.dart';

/// Affiche un dialog animé quand l'opérateur quitte le control robot.
/// Retourne true si mission terminée, false si juste retour.
Future<bool> showMissionEndDialog(
    BuildContext context, MissionModel mission) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (_, anim, __, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
    pageBuilder: (_, __, ___) => _MissionEndDialog(mission: mission),
  );
  return result ?? false;
}

class _MissionEndDialog extends StatefulWidget {
  final MissionModel mission;
  const _MissionEndDialog({required this.mission});
  @override
  State<_MissionEndDialog> createState() => _MissionEndDialogState();
}

class _MissionEndDialogState extends State<_MissionEndDialog>
    with TickerProviderStateMixin {
  static const _bg   = Color(0xFF07111E);
  static const _card = Color(0xFF0D1F35);
  static const _cyan = Color(0xFF00E5FF);
  static const _red  = Color(0xFFFF3B3B);
  static const _green= Color(0xFF00E676);

  late final AnimationController _pulseCtrl;
  late final AnimationController _radarCtrl;
  late final Animation<double>   _pulseAnim;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _radarCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _radarCtrl.dispose();
    super.dispose();
  }

  Future<void> _endMission() async {
    HapticFeedback.heavyImpact();
    setState(() => _loading = true);
    await MissionState.instance.completeMission(widget.mission.dbId);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _justLeave() {
    HapticFeedback.lightImpact();
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _cyan.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: _cyan.withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: 4),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopAccent(),
            _buildIcon(),
            _buildTexts(),
            _buildMissionInfo(),
            _buildButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Barre colorée en haut ─────────────────────────────────────────────────
  Widget _buildTopAccent() => Container(
        height: 4,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          gradient: LinearGradient(colors: [
            _cyan.withOpacity(0),
            _cyan,
            _cyan.withOpacity(0),
          ]),
        ),
      );

  // ─── Icône radar animée ───────────────────────────────────────────────────
  Widget _buildIcon() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 4),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: _pulseAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: 80, height: 80,
          child: AnimatedBuilder(
            animation: _radarCtrl,
            builder: (_, __) => CustomPaint(
              painter: _RadarPainter(_radarCtrl.value),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Textes ───────────────────────────────────────────────────────────────
  Widget _buildTexts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Text('QUITTER LE CONTRÔLE',
              style: TextStyle(
                  color: _cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(
            'Souhaitez-vous terminer la mission en cours\navant de quitter ?',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── Carte mission active ─────────────────────────────────────────────────
  Widget _buildMissionInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cyan.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _green,
              boxShadow: [
                BoxShadow(color: _green.withOpacity(0.5), blurRadius: 6)
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.mission.name,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                    '${widget.mission.type.emoji} ${widget.mission.type.label}  •  ${widget.mission.duration}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                        fontFamily: 'monospace')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Boutons ──────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // ✅ Terminer la mission
          GestureDetector(
            onTap: _loading ? null : _endMission,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF00B8D4), Color(0xFF00E5FF)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: _cyan.withOpacity(0.3), blurRadius: 20)
                ],
              ),
              child: _loading
                  ? Center(
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF07111E)),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: const Color(0xFF07111E), size: 20),
                        const SizedBox(width: 8),
                        Text('TERMINER LA MISSION',
                            style: TextStyle(
                                color: const Color(0xFF07111E),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.5)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          // ↩ Juste retourner
          GestureDetector(
            onTap: _loading ? null : _justLeave,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cyan.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded,
                      color: Colors.white.withOpacity(0.4), size: 18),
                  const SizedBox(width: 8),
                  Text('JUSTE RETOURNER',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Radar painter ─────────────────────────────────────────────────────────────
class _RadarPainter extends CustomPainter {
  final double t;
  const _RadarPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    const cyan = Color(0xFF00E5FF);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(c, r, ringPaint..color = cyan.withOpacity(0.25));
    canvas.drawCircle(c, r * 0.6, ringPaint..color = cyan.withOpacity(0.12));
    canvas.drawCircle(c, r * 0.3, ringPaint..color = cyan.withOpacity(0.08));

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2 + t * 2 * math.pi,
      math.pi / 2,
      true,
      Paint()
        ..shader = RadialGradient(
                colors: [cyan.withOpacity(0.8), Colors.transparent])
            .createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.fill,
    );

    final angle = -math.pi / 2 + t * 2 * math.pi;
    canvas.drawCircle(
      Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle)),
      5,
      Paint()
        ..color = cyan
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(_RadarPainter o) => o.t != t;
}