// lib/features/mission/presentation/pages/mission_list_page.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mission_model.dart';
import '../../data/mission_state.dart';
import 'new_mission_page.dart';
import 'mission_detail_sheet.dart'; // ✅

class MissionListPage extends StatefulWidget {
  const MissionListPage({super.key});
  @override
  State<MissionListPage> createState() => _MissionListPageState();
}

class _MissionListPageState extends State<MissionListPage>
    with TickerProviderStateMixin {
  static const _cyan   = Color(0xFF00E5FF);
  static const _bg     = Color(0xFF07111E);
  static const _cardBg = Color(0xFF0D1F35);
  static const _red    = Color(0xFFFF3B3B);
  static const _green  = Color(0xFF00E676);

  final _state = MissionState.instance;

  late final AnimationController _enterCtrl;
  late final AnimationController _radarCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _radarCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))..repeat();

    _enterCtrl.forward();

    // ✅ Charger les missions depuis la BD au démarrage
    _state.loadMissions();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _radarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const _GridBg(),
          _buildRadarDecor(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                // ✅ ListenableBuilder — rebuild quand MissionState change
                child: ListenableBuilder(
                  listenable: _state,
                  builder: (context, _) => Column(
                    children: [
                      _buildHeader(context),
                      _buildStats(),
                      Expanded(child: _buildBody()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  // ─── Body (loading / error / list) ────────────────────────────────────────

  Widget _buildBody() {
    if (_state.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _cyan.withOpacity(0.5)),
            ),
            const SizedBox(height: 14),
            Text('Chargement des missions...',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 12)),
          ],
        ),
      );
    }

    if (_state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: _red.withOpacity(0.5), size: 40),
            const SizedBox(height: 14),
            Text(_state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: _red.withOpacity(0.7), fontSize: 12)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _state.loadMissions,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _cyan.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: _cyan, size: 16),
                    const SizedBox(width: 8),
                    Text('RÉESSAYER',
                        style: TextStyle(
                            color: _cyan,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_state.missions.isEmpty) return _buildEmpty();
    return _buildList();
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), // ✅ ajout du 16
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cyan.withOpacity(0.25)),
            ),
            child: Icon(Icons.arrow_back_ios_rounded, color: _cyan, size: 16),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JOURNAL DES MISSIONS',
                style: TextStyle(
                  color: _cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                'Historique des opérations',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12), // ✅ ajout du 12
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _state.loadMissions();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cyan.withOpacity(0.2)),
            ),
            child: Icon(Icons.refresh_rounded, color: _cyan, size: 18),
          ),
        ),
      ],
    ),
  );
}

  // ─── Stats ────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    final total     = _state.missions.length;
    final completed = _state.missions
        .where((m) => m.status == MissionStatus.completed).length;
    final aborted   = _state.missions
        .where((m) => m.status == MissionStatus.aborted).length;
    final active    = _state.activeMission != null ? 1 : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: [
          _statChip('TOTAL',     '$total',     Colors.white.withOpacity(0.5)),
          const SizedBox(width: 8),
          _statChip('ACTIVES',   '$active',    _cyan),
          const SizedBox(width: 8),
          _statChip('TERMINÉES', '$completed', _green),
          const SizedBox(width: 8),
          _statChip('ANNULÉES',  '$aborted',   _red),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 1),
            Text(label,
                style: TextStyle(
                    color: color.withOpacity(0.6),
                    fontSize: 8,
                    letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }

  // ─── Liste ────────────────────────────────────────────────────────────────

  Widget _buildList() {
    final all = _state.missions;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: all.length,
      itemBuilder: (ctx, i) => _MissionCard(
        mission:  all[i],
        onTap:    () => showMissionDetail(context, all[i]), // ✅
        onDelete: () => _confirmDelete(context, all[i]),
      ),
    );
  }

  // ─── Empty ────────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80, height: 80,
            child: AnimatedBuilder(
              animation: _radarCtrl,
              builder: (_, __) => Opacity(
                opacity: 0.3,
                child: CustomPaint(
                    painter: _RadarPainter(_radarCtrl.value)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('AUCUNE MISSION',
              style: TextStyle(
                  color: _cyan.withOpacity(0.4),
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Text('Déployez votre première mission',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.2), fontSize: 12)),
        ],
      ),
    );
  }

  // ─── Confirm delete ────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, MissionModel mission) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _red.withOpacity(0.4)),
        ),
        title: Text('SUPPRIMER ?',
            style: TextStyle(
                color: _red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        content: Text(
          'Supprimer "${mission.name}" définitivement ?',
          style: TextStyle(
              color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ANNULER',
                style: TextStyle(color: Colors.white.withOpacity(0.4))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final err = await _state.deleteMission(mission.dbId);
              if (!context.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: _cardBg,
                  content: Text(err,
                      style: TextStyle(color: _red)),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
            child: Text('SUPPRIMER',
                style: TextStyle(
                    color: _red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── FAB ──────────────────────────────────────────────────────────────────
Widget _buildFab(BuildContext context) {
  final hasActive = _state.activeMission != null;

  return GestureDetector(
    onTap: () {
      // ✅ Bloquer si une mission est déjà active
      if (hasActive) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0D1F35),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _red.withOpacity(0.5)),
            ),
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: _red, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Une mission est déjà en cours. Terminez-la avant d\'en créer une nouvelle.',
                    style: TextStyle(color: _red, fontSize: 12),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const NewMissionPage(),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween(
                begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ).then((_) => _state.loadMissions());
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      decoration: BoxDecoration(
        gradient: hasActive
            ? null
            : const LinearGradient(
                colors: [Color(0xFF00B8D4), Color(0xFF00E5FF)]),
        color: hasActive ? const Color(0xFF0D1F35) : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasActive ? _red.withOpacity(0.5) : _cyan,
          width: 1.5,
        ),
        boxShadow: hasActive
            ? []
            : [
                BoxShadow(
                    color: _cyan.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2)
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasActive ? Icons.lock_rounded : Icons.add_rounded,
            color: hasActive ? _red.withOpacity(0.7) : const Color(0xFF07111E),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            hasActive ? 'MISSION EN COURS' : 'NOUVELLE MISSION',
            style: TextStyle(
                color: hasActive
                    ? _red.withOpacity(0.7)
                    : const Color(0xFF07111E),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.5),
          ),
        ],
      ),
    ),
  );
}
 

  Widget _buildRadarDecor() {
    return Positioned(
      bottom: -40, left: -40,
      child: AnimatedBuilder(
        animation: _radarCtrl,
        builder: (_, __) => Opacity(
          opacity: 0.04,
          child: SizedBox(
            width: 200, height: 200,
            child: CustomPaint(
                painter: _RadarBgPainter(_radarCtrl.value)),
          ),
        ),
      ),
    );
  }
}

// ─── Mission Card avec swipe to delete ────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  final MissionModel mission;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  const _MissionCard({required this.mission, required this.onDelete, required this.onTap});

  static const _cardBg = Color(0xFF0D1F35);
  static const _red    = Color(0xFFFF3B3B);
  static const _green  = Color(0xFF00E676);
  static const _cyan   = Color(0xFF00E5FF);

  Color get _typeColor   => mission.type.color;
  Color get _statusColor {
    switch (mission.status) {
      case MissionStatus.completed: return _green;
      case MissionStatus.aborted:   return _red;
      case MissionStatus.active:    return _cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(mission.dbId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // Le state gère la suppression
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _red.withOpacity(0.4)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: _red, size: 24),
            const SizedBox(height: 4),
            Text('SUPPRIMER',
                style: TextStyle(
                    color: _red,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap, // ✅ tap → ouvre le détail
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _statusColor.withOpacity(0.18)),
          ),
          child: Column(
            children:  [
            // Barre colorée en haut
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                gradient: LinearGradient(colors: [
                  _typeColor.withOpacity(0),
                  _typeColor,
                  _typeColor.withOpacity(0),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + status + bouton delete
                  Row(
                    children: [
                      Expanded(
                        child: Text(mission.name,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      _statusBadge(),
                      const SizedBox(width: 8),
                      // Bouton supprimer
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: _red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _red.withOpacity(0.25)),
                          ),
                          child: Icon(Icons.delete_outline_rounded,
                              color: _red.withOpacity(0.7), size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Type + ID + durée
                  Row(
                    children: [
                      _pill(mission.type.emoji, mission.type.label,
                          _typeColor),
                      const SizedBox(width: 6),
                      _pill(null, mission.id,
                          Colors.white.withOpacity(0.3)),
                      const Spacer(),
                      Icon(Icons.access_time_rounded,
                          color: Colors.white.withOpacity(0.25),
                          size: 12),
                      const SizedBox(width: 3),
                      Text(mission.duration,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 11,
                              fontFamily: 'monospace')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: Colors.white.withOpacity(0.2),
                          size: 11),
                      const SizedBox(width: 4),
                      Text(
                          '${mission.formattedDate} à ${mission.formattedTime}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.25),
                              fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),         // ← ferme Column
      ),           // ← ferme Container
      ),           // ← ferme GestureDetector
    );             // ← ferme Dismissible
  }

  Widget _statusBadge() => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: _statusColor.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5, height: 5,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: _statusColor),
            ),
            const SizedBox(width: 5),
            Text(mission.status.label,
                style: TextStyle(
                    color: _statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ],
        ),
      );

  Widget _pill(String? emoji, String text, Color color) =>
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Text(
          emoji != null ? '$emoji $text' : text,
          style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600),
        ),
      );
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _GridBg extends StatelessWidget {
  const _GridBg();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter(), size: Size.infinite);
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.03)
      ..strokeWidth = 0.5;
    const step = 36.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _RadarBgPainter extends CustomPainter {
  final double t;
  const _RadarBgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(c, r * i / 3,
          p..color = const Color(0xFF00E5FF).withOpacity(0.4));
    }
  }
  @override
  bool shouldRepaint(_RadarBgPainter o) => o.t != t;
}

class _RadarPainter extends CustomPainter {
  final double t;
  const _RadarPainter(this.t);
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
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2 + t * 2 * math.pi,
      math.pi / 2,
      true,
      Paint()
        ..shader = RadialGradient(
                colors: [cyan.withOpacity(0.6), Colors.transparent])
            .createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.fill,
    );
  }
  @override
  bool shouldRepaint(_RadarPainter o) => o.t != t;
}