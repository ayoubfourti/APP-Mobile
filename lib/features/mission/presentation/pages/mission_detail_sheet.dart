// lib/features/mission/presentation/pages/mission_detail_sheet.dart
import '../../../../core/services/victim_service.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mission_model.dart';
import '../../data/mission_state.dart';

/// Affiche le détail d'une mission dans un bottom sheet animé
void showMissionDetail(BuildContext context, MissionModel mission) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _MissionDetailSheet(mission: mission),
  );
}

class _MissionDetailSheet extends StatefulWidget {
  final MissionModel mission;
  const _MissionDetailSheet({required this.mission});
  @override
  State<_MissionDetailSheet> createState() => _MissionDetailSheetState();
}

class _MissionDetailSheetState extends State<_MissionDetailSheet>
    with TickerProviderStateMixin {
  static const _bg   = Color(0xFF07111E);
  static const _card = Color(0xFF0D1F35);
  static const _cyan = Color(0xFF00E5FF);
  static const _red  = Color(0xFFFF3B3B);
  static const _green= Color(0xFF00E676);

  late final AnimationController _enterCtrl;
  late final AnimationController _radarCtrl;
  late final AnimationController _pulseCtrl;
  late final List<AnimationController> _rowCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Valeurs statiques (à connecter à la BD plus tard)
  int get _victimCount => VictimService.instance.totalUnique;
  static const double _batteryUsed = 42.0; // %

  final _rows = const [0, 1, 2, 3, 4, 5]; // ✅ 6 lignes (place ajoutée)

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _radarCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);

    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    // Stagger des lignes de stats
    _rowCtrl = List.generate(_rows.length, (i) =>
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350)));

    _enterCtrl.forward();
    for (int i = 0; i < _rows.length; i++) {
      Future.delayed(Duration(milliseconds: 150 + i * 80), () {
        if (mounted) _rowCtrl[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _radarCtrl.dispose();
    _pulseCtrl.dispose();
    for (final c in _rowCtrl) c.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.mission.status) {
      case MissionStatus.active:    return _cyan;
      case MissionStatus.completed: return _green;
      case MissionStatus.aborted:   return _red;
    }
  }

  IconData get _statusIcon {
    switch (widget.mission.status) {
      case MissionStatus.active:    return Icons.radar_rounded;
      case MissionStatus.completed: return Icons.check_circle_rounded;
      case MissionStatus.aborted:   return Icons.cancel_rounded;
    }
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
            border: Border.all(
                color: _statusColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: _statusColor.withOpacity(0.06),
                  blurRadius: 40,
                  spreadRadius: 4),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                _buildHero(),
                _buildDivider(),
                // ✅ Stats scrollable pour éviter l'overflow
                Flexible(
  child: SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: ListenableBuilder(
      listenable: VictimService.instance,
      builder: (_, __) => _buildStatRows(),
    ),
  ),
),
                if (widget.mission.status == MissionStatus.active)
                  _buildActionRow(),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
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
            color: _cyan.withOpacity(0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  // ─── Hero — nom + type + radar ────────────────────────────────────────────
  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radar / status animé
          SizedBox(
            width: 64, height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _radarCtrl,
                  builder: (_, __) => CustomPaint(
                    size: const Size(64, 64),
                    painter: _RadarPainter(_radarCtrl.value, _statusColor),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Icon(
                    _statusIcon,
                    color: _statusColor.withOpacity(
                        0.5 + _pulseCtrl.value * 0.5),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusBadge(),
                const SizedBox(height: 8),
                Text(
                  widget.mission.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(widget.mission.id,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace')),
                const SizedBox(height: 8),
                _pill(
                    '${widget.mission.type.emoji}  ${widget.mission.type.label}',
                    widget.mission.type.color),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    final isActive = widget.mission.status == MissionStatus.active;
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor
              .withOpacity(isActive ? 0.08 + _pulseCtrl.value * 0.06 : 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _statusColor.withOpacity(
                isActive ? 0.4 + _pulseCtrl.value * 0.3 : 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor,
                boxShadow: [
                  BoxShadow(color: _statusColor.withOpacity(0.6), blurRadius: 4)
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(widget.mission.status.label,
                style: TextStyle(
                    color: _statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  // ─── Divider ──────────────────────────────────────────────────────────────
  Widget _buildDivider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            _cyan.withOpacity(0.15),
            Colors.transparent,
          ]),
        ),
      );

  // ─── Lignes de stats animées ───────────────────────────────────────────────
  Widget _buildStatRows() {
    // ✅ Couleur de la ligne "place" selon la valeur
    final placeValue  = widget.mission.place;
    final placeIsReal = placeValue != 'AUTO' &&
        placeValue != 'GPS désactivé' &&
        placeValue != 'Permission refusée' &&
        placeValue != 'Permission refusée définitivement';
    final placeColor  = placeIsReal ? const Color(0xFF69F0AE) : _red.withOpacity(0.8);

    final rows = [
      // ✅ Ligne 0 — Position de l'opérateur
      _StatData(
        icon:  Icons.location_on_rounded,
        label: 'POSITION DE L\'OPÉRATEUR',
        value: placeValue,
        color: placeColor,
      ),
      // Ligne 1 — Date de début
      _StatData(
        icon:  Icons.calendar_today_rounded,
        label: 'DATE DE DÉBUT',
        value: '${widget.mission.formattedDate} à ${widget.mission.formattedTime}',
        color: _cyan,
      ),
      // Ligne 2 — Durée
      _StatData(
        icon:        Icons.timer_rounded,
        label:       'DURÉE DE LA MISSION',
        value:       widget.mission.duration,
        color:       _cyan,
        isMonospace: true,
      ),
      // Ligne 3 — Date de fin
      _StatData(
        icon:  Icons.flag_rounded,
        label: 'DATE DE FIN',
        value: widget.mission.endTime != null
            ? '${_fmtDate(widget.mission.endTime!)} à ${_fmtTime(widget.mission.endTime!)}'
            : 'En cours...',
        color: widget.mission.endTime != null
            ? Colors.white.withOpacity(0.6)
            : _cyan,
      ),
      // Ligne 4 — Victimes (statique)
      _StatData(
        icon:  Icons.person_search_rounded,
        label: 'VICTIMES DÉTECTÉES',
        value: '$_victimCount victime${_victimCount > 1 ? 's' : ''}',
        color: _victimCount > 0 ? const Color(0xFFFFD600) : _green,
        badge: 'STATIQUE',
      ),
      // Ligne 5 — Batterie (statique)
      _StatData(
        icon:     Icons.battery_charging_full_rounded,
        label:    'BATTERIE UTILISÉE',
        value:    '${_batteryUsed.toStringAsFixed(0)}%',
        color:    _batteryUsed > 60
            ? _red
            : _batteryUsed > 30
                ? const Color(0xFFFFD600)
                : _green,
        badge:    'STATIQUE',
        hasBar:   true,
        barValue: _batteryUsed / 100,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: List.generate(rows.length, (i) {
          return AnimatedBuilder(
            animation: _rowCtrl[i],
            builder: (_, child) {
              final v = _rowCtrl[i].value;
              return Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(20 * (1 - v), 0),
                  child: child,
                ),
              );
            },
            child: _buildStatRow(rows[i]),
          );
        }),
      ),
    );
  }

  Widget _buildStatRow(_StatData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.color.withOpacity(0.1),
                ),
                child: Icon(data.icon, color: data.color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(data.label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5)),
              ),
              if (data.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(data.badge!,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 8,
                          letterSpacing: 1)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.value,
                    style: TextStyle(
                        color: data.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: data.isMonospace ? 'monospace' : null)),
                if (data.hasBar) ...[
                  const SizedBox(height: 8),
                  _buildBar(data.barValue!, data.color),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double value, Color color) {
    return LayoutBuilder(builder: (_, constraints) {
      return Stack(
        children: [
          Container(
            height: 6,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            height: 6,
            width: constraints.maxWidth * value,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.6), color]),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)],
            ),
          ),
        ],
      );
    });
  }

  // ─── Boutons action si mission active ─────────────────────────────────────
  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await MissionState.instance.completeMission(widget.mission.dbId);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF00B8D4), Color(0xFF00E5FF)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _cyan.withOpacity(0.3), blurRadius: 16)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: const Color(0xFF07111E), size: 18),
                    const SizedBox(width: 8),
                    Text('TERMINER',
                        style: TextStyle(
                            color: const Color(0xFF07111E),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 1.5)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await MissionState.instance.abortMission(widget.mission.dbId);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _red.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_rounded, color: _red, size: 18),
                    const SizedBox(width: 8),
                    Text('ANNULER',
                        style: TextStyle(
                            color: _red,
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

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      );

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}h'
      '${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Data model ───────────────────────────────────────────────────────────────
class _StatData {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  final String?  badge;
  final bool     isMonospace;
  final bool     hasBar;
  final double?  barValue;

  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.badge,
    this.isMonospace = false,
    this.hasBar      = false,
    this.barValue,
  });
}

// ─── Radar painter ─────────────────────────────────────────────────────────────
class _RadarPainter extends CustomPainter {
  final double t;
  final Color  color;
  const _RadarPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    canvas.drawCircle(c, r,
        Paint()
          ..color = color.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawCircle(c, r * 0.55,
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2 + t * 2 * math.pi,
      math.pi / 2,
      true,
      Paint()
        ..shader = RadialGradient(
                colors: [color.withOpacity(0.5), Colors.transparent])
            .createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.fill,
    );

    final angle = -math.pi / 2 + t * 2 * math.pi;
    canvas.drawCircle(
      Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle)),
      3.5,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_RadarPainter o) => o.t != t;
}