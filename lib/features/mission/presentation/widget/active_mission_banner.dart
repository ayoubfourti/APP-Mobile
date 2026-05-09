// lib/features/mission/presentation/widgets/active_mission_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mission_model.dart';
import '../../data/mission_state.dart';
import '../pages/new_mission_page.dart';
import '../pages/mission_list_page.dart';

/// ✅ StatelessWidget pur — aucun Timer, aucun setState
/// Le parent (AnimatedBuilder de ToolsPage) rebuild déjà chaque frame
class ActiveMissionBanner extends StatelessWidget {
  const ActiveMissionBanner({super.key});

  static const _cyan   = Color(0xFF00E5FF);
  static const _red    = Color(0xFFFF3B3B);
  static const _cardBg = Color(0xFF0D1F35);

  @override
  Widget build(BuildContext context) {
    final active = MissionState.instance.activeMission;
    if (active == null) return _buildNoMission(context);
    return _buildActiveMission(context, active);
  }

  // ─── Aucune mission ──────────────────────────────────────────────────────

  Widget _buildNoMission(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, _fadeRoute(const NewMissionPage())),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cyan.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyan.withOpacity(0.1),
                border: Border.all(color: _cyan.withOpacity(0.4)),
              ),
              child: const Icon(Icons.add, color: _cyan, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NOUVELLE MISSION',
                      style: TextStyle(
                          color: _cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text('Aucune mission active',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context, _fadeRoute(const MissionListPage())),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: _cyan.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('HISTORIQUE',
                    style: TextStyle(
                        color: _cyan.withOpacity(0.7),
                        fontSize: 10,
                        letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mission active ──────────────────────────────────────────────────────

  Widget _buildActiveMission(BuildContext context, MissionModel mission) {
    final elapsed = mission.duration;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cyan.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _cyan.withOpacity(0.08),
              blurRadius: 16,
              spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _cyan.withOpacity(0.07),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cyan.withOpacity(
                      (DateTime.now().millisecondsSinceEpoch % 1000) < 500
                          ? 1.0
                          : 0.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: _cyan.withOpacity(0.5), blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('MISSION ACTIVE',
                    style: TextStyle(
                        color: _cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                const Spacer(),
                Text(elapsed,
                    style: const TextStyle(
                        color: _cyan,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1.5)),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.name,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(mission.id,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _tag(mission.zone, _cyan),
                          const SizedBox(width: 6),
                          _tag(
                              '${mission.type.emoji} ${mission.type.label}',
                              Colors.white.withOpacity(0.6)),
                        ],
                      ),
                      if (mission.note != null) ...[
                        const SizedBox(height: 6),
                        Text(mission.note!,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                      // ✅ Indication que la création est bloquée
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _red.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded,
                                color: _red.withOpacity(0.7), size: 11),
                            const SizedBox(width: 4),
                            Text('Nouvelle mission bloquée',
                                style: TextStyle(
                                    color: _red.withOpacity(0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _actionBtn(
                      context: context,
                      label: 'TERMINER',
                      color: _cyan,
                      icon: Icons.check_circle_outline,
                      onTap: () => _confirmEnd(context, mission.dbId, false),
                    ),
                    const SizedBox(height: 6),
                    _actionBtn(
                      context: context,
                      label: 'ANNULER',
                      color: _red,
                      icon: Icons.cancel_outlined,
                      onTap: () => _confirmEnd(context, mission.dbId, true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _tag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      );

  Widget _actionBtn({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
            ],
          ),
        ),
      );

  void _confirmEnd(BuildContext context, int dbId, bool abort) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: abort
                  ? _red.withOpacity(0.5)
                  : _cyan.withOpacity(0.5)),
        ),
        title: Text(
          abort ? 'ANNULER LA MISSION ?' : 'TERMINER LA MISSION ?',
          style: TextStyle(
              color: abort ? _red : _cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        content: Text(
          abort
              ? 'La mission sera marquée comme annulée.'
              : 'La mission sera marquée comme terminée avec succès.',
          style: TextStyle(
              color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('RETOUR',
                style: TextStyle(color: Colors.white.withOpacity(0.4))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (abort) {
                MissionState.instance.abortMission(dbId);
              } else {
                MissionState.instance.completeMission(dbId);
              }
            },
            child: Text('CONFIRMER',
                style: TextStyle(
                    color: abort ? _red : _cyan,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      );
}