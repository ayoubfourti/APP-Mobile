// lib/features/mission/presentation/widgets/mission_select_dialog.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mission_model.dart';
import '../../data/mission_state.dart';

/// Affiche un bottom sheet animé pour sélectionner une mission active.
/// Retourne la [MissionModel] choisie ou null si annulé.
Future<MissionModel?> showMissionSelectDialog(BuildContext context) {
  return showModalBottomSheet<MissionModel>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => const _MissionSelectSheet(),
  );
}

class _MissionSelectSheet extends StatefulWidget {
  const _MissionSelectSheet();
  @override
  State<_MissionSelectSheet> createState() => _MissionSelectSheetState();
}

class _MissionSelectSheetState extends State<_MissionSelectSheet>
    with TickerProviderStateMixin {
  static const _bg     = Color(0xFF07111E);
  static const _card   = Color(0xFF0D1F35);
  static const _cyan   = Color(0xFF00E5FF);
  static const _red    = Color(0xFFFF3B3B);

  late final AnimationController _enterCtrl;
  late final AnimationController _radarCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  MissionModel? _selected;
  final _state = MissionState.instance;

  // Missions actives uniquement
  List<MissionModel> get _actives =>
      _state.missions.where((m) => m.status == MissionStatus.active).toList();

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _radarCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat();

    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _enterCtrl.forward();

    // Auto-sélectionner si une seule mission active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_actives.length == 1) setState(() => _selected = _actives.first);
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _radarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _cyan.withOpacity(0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: _cyan.withOpacity(0.08),
                  blurRadius: 40,
                  spreadRadius: 4),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHeader(),
              const SizedBox(height: 8),
              _buildBody(),
              _buildActions(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Poignée ──────────────────────────────────────────────────────────────
  Widget _buildHandle() => Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: _cyan.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          // Radar animé
          SizedBox(
            width: 42, height: 42,
            child: AnimatedBuilder(
              animation: _radarCtrl,
              builder: (_, __) => CustomPaint(
                  painter: _RadarMiniPainter(_radarCtrl.value)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SÉLECTION DE MISSION',
                    style: TextStyle(
                        color: _cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 2)),
                const SizedBox(height: 2),
                Text('Choisir une mission active à superviser',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.35), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Corps ────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_actives.isEmpty) return _buildEmpty();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        itemCount: _actives.length,
        itemBuilder: (_, i) => _buildMissionTile(_actives[i]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, color: _cyan.withOpacity(0.2), size: 48),
          const SizedBox(height: 12),
          Text('AUCUNE MISSION ACTIVE',
              style: TextStyle(
                  color: _cyan.withOpacity(0.4),
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 6),
          Text('Créez une mission depuis le tableau de bord',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.25), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMissionTile(MissionModel mission) {
    final isSelected = _selected?.dbId == mission.dbId;
    final typeColor  = mission.type.color;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selected = mission);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? _cyan.withOpacity(0.07) : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _cyan.withOpacity(0.7) : _cyan.withOpacity(0.12),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _cyan.withOpacity(0.15), blurRadius: 16)]
              : [],
        ),
        child: Row(
          children: [
            // Icône type
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withOpacity(isSelected ? 0.15 : 0.07),
                border: Border.all(
                    color: typeColor.withOpacity(isSelected ? 0.5 : 0.2)),
              ),
              child: Center(
                child: Text(mission.type.emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mission.name,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _pill(mission.type.label, typeColor),
                      const SizedBox(width: 6),
                      Text(mission.id,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('Démarrée il y a ${mission.duration}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 10,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
            // Check
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _cyan : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _cyan : _cyan.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded,
                      color: const Color(0xFF07111E), size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 9, fontWeight: FontWeight.bold)),
      );

  // ─── Actions ──────────────────────────────────────────────────────────────
  Widget _buildActions() {
    final canConfirm = _selected != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Annuler
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context, null),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _cyan.withOpacity(0.15)),
                ),
                child: Text('ANNULER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Confirmer
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: canConfirm
                  ? () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, _selected);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: canConfirm
                      ? const LinearGradient(
                          colors: [Color(0xFF00B8D4), Color(0xFF00E5FF)])
                      : null,
                  color: canConfirm ? null : _card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: canConfirm ? _cyan : _cyan.withOpacity(0.1)),
                  boxShadow: canConfirm
                      ? [
                          BoxShadow(
                              color: _cyan.withOpacity(0.3), blurRadius: 20)
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rocket_launch_rounded,
                        color: canConfirm
                            ? const Color(0xFF07111E)
                            : _cyan.withOpacity(0.2),
                        size: 18),
                    const SizedBox(width: 8),
                    Text('DÉMARRER',
                        style: TextStyle(
                            color: canConfirm
                                ? const Color(0xFF07111E)
                                : _cyan.withOpacity(0.2),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 1.5)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini radar painter ────────────────────────────────────────────────────────
class _RadarMiniPainter extends CustomPainter {
  final double t;
  const _RadarMiniPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    const cyan = Color(0xFF00E5FF);

    canvas.drawCircle(c, r,
        Paint()
          ..color = cyan.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawCircle(c, r * 0.6,
        Paint()
          ..color = cyan.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2 + t * 2 * math.pi,
      math.pi / 2,
      true,
      Paint()
        ..shader = RadialGradient(
                colors: [cyan.withOpacity(0.7), Colors.transparent])
            .createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.fill,
    );

    final angle = -math.pi / 2 + t * 2 * math.pi;
    canvas.drawCircle(
      Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle)),
      3,
      Paint()
        ..color = cyan
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(_RadarMiniPainter o) => o.t != t;
}