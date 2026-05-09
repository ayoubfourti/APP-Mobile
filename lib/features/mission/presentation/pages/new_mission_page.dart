import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mission_model.dart';
import '../../data/mission_state.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/slam_map_service.dart';

class NewMissionPage extends StatefulWidget {
  const NewMissionPage({super.key});
  @override
  State<NewMissionPage> createState() => _NewMissionPageState();
}

class _NewMissionPageState extends State<NewMissionPage>
    with TickerProviderStateMixin {
  static const _bg     = Color(0xFF07111E);
  static const _cyan   = Color(0xFF00E5FF);
  static const _red    = Color(0xFFFF3B3B);
  static const _cardBg = Color(0xFF0D1F35);

  final _state     = MissionState.instance;
  final _cinCtrl   = TextEditingController();   // ✅ CIN
  final _nameCtrl  = TextEditingController();
  final _cinFocus  = FocusNode();               // ✅
  final _nameFocus = FocusNode();
  MissionType? _selectedType;
  bool    _launching    = false;
  bool    _nameHasFocus = false;
  bool    _cinHasFocus  = false;               // ✅
  String? _apiError;
  String? _cinError;                           // ✅ erreur validation CIN

  LocationResult? _locationResult;
  bool _locationLoading = true;

  late final AnimationController _enterCtrl;
  late final AnimationController _radarCtrl;
  late final AnimationController _launchCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _nameShakeCtrl;
  late final AnimationController _cinShakeCtrl; // ✅
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;
  late final Animation<double>   _pulseAnim;
  late final Animation<double>   _launchAnim;
  late final Animation<double>   _shakeAnim;
  late final Animation<double>   _cinShakeAnim; // ✅

  late final List<AnimationController> _cardCtrl;
  late final List<CurvedAnimation>     _cardCurved;
  late final List<Animation<double>>   _cardScale;

  final _types = const [
    (MissionType.search, Icons.search_rounded,         'RECHERCHE',      'Localiser des survivants',     Color(0xFF00E5FF)),
    (MissionType.rescue, Icons.local_hospital_rounded, 'SAUVETAGE',      'Extraction en zone de danger', Color(0xFFFF6B6B)),
    (MissionType.recon,  Icons.explore_rounded,        'RECONNAISSANCE', 'Cartographier le terrain',     Color(0xFFFFD600)),
  ];

  @override
  void initState() {
    super.initState();
    _enterCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim      = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim     = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _radarCtrl     = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _launchCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _launchAnim    = CurvedAnimation(parent: _launchCtrl, curve: Curves.easeInOut);
    _pulseCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _pulseAnim     = Tween<double>(begin: 1.0, end: 1.035)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _nameShakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim     = Tween<double>(begin: 0, end: 1).animate(_nameShakeCtrl);
    _cinShakeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400)); // ✅
    _cinShakeAnim  = Tween<double>(begin: 0, end: 1).animate(_cinShakeCtrl);                        // ✅

    _cardCtrl   = List.generate(_types.length, (i) =>
        AnimationController(vsync: this, duration: const Duration(milliseconds: 280)));
    _cardCurved = List.generate(_types.length, (i) =>
        CurvedAnimation(parent: _cardCtrl[i], curve: Curves.easeOut));
    _cardScale  = List.generate(_types.length, (i) =>
        Tween<double>(begin: 1.0, end: 0.95).animate(_cardCurved[i]));

    _nameFocus.addListener(() => setState(() => _nameHasFocus = _nameFocus.hasFocus));
    _cinFocus.addListener(()  => setState(() => _cinHasFocus  = _cinFocus.hasFocus));  // ✅
    _nameCtrl.addListener(() => setState(() {}));
    _cinCtrl.addListener(()  => setState(() => _cinError = null));                      // ✅ reset erreur

    _enterCtrl.forward();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() => _locationLoading = true);
    final result = await LocationService.getLocation();
    if (mounted) setState(() { _locationResult = result; _locationLoading = false; });
  }

  @override
  void dispose() {
    _enterCtrl.dispose(); _radarCtrl.dispose(); _launchCtrl.dispose();
    _pulseCtrl.dispose(); _nameShakeCtrl.dispose(); _cinShakeCtrl.dispose();
    for (final c in _cardCtrl)   c.dispose();
    for (final c in _cardCurved) c.dispose();
    _nameCtrl.dispose(); _nameFocus.dispose();
    _cinCtrl.dispose();  _cinFocus.dispose();
    super.dispose();
  }

  // ✅ CIN valide = 8 chiffres exactement
  bool get _cinValid => RegExp(r'^\d{8}$').hasMatch(_cinCtrl.text.trim());

  bool get _canLaunch =>
      _cinValid &&
      _nameCtrl.text.trim().isNotEmpty &&
      _selectedType != null;

  void _selectType(int i) {
    HapticFeedback.lightImpact();
    _cardCtrl[i].forward().then((_) => _cardCtrl[i].reverse());
    setState(() => _selectedType = _types[i].$1);
  }

  Future<void> _launch() async {
    if (_launching) return;

    // ── Validation CIN ─────────────────────────────────
    if (!_cinValid) {
      _cinShakeCtrl.forward(from: 0);
      _cinFocus.requestFocus();
      HapticFeedback.mediumImpact();
      setState(() => _cinError = 'Le CIN doit contenir exactement 8 chiffres');
      return;
    }

    // ── Validation nom ──────────────────────────────────
    if (_nameCtrl.text.trim().isEmpty) {
      _nameShakeCtrl.forward(from: 0);
      _nameFocus.requestFocus();
      HapticFeedback.mediumImpact();
      return;
    }

    if (_selectedType == null) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() { _launching = true; _apiError = null; });

    final error = await _state.createMission(
      name:        _nameCtrl.text.trim(),
      type:        _selectedType!,
      operatorCin: int.parse(_cinCtrl.text.trim()), // ✅
    );

    if (!mounted) return;

    if (error != null) {
      setState(() { _launching = false; _apiError = error; });
      return;
    }

    // 🆕 Reset la carte de la mission précédente avant nouvelle mission
    SlamMapService.instance.resetMap();
    await _launchCtrl.forward();
    if (!mounted) return;
    Navigator.pop(context);
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
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.translucent,
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildCinField(),        // ✅ étape 1 — CIN
                              const SizedBox(height: 28),
                              _buildNameField(),       // étape 2 — nom
                              const SizedBox(height: 28),
                              _buildZoneBadge(),       // étape 3 — position
                              const SizedBox(height: 28),
                              _buildTypeSection(),     // étape 4 — type
                              if (_apiError != null) ...[
                                const SizedBox(height: 16),
                                _buildErrorBanner(),
                              ],
                              const SizedBox(height: 32),
                              _buildLaunchBtn(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_launching && _apiError == null) _buildLaunchOverlay(),
        ],
      ),
    );
  }

  // ── Champ CIN ✅ ─────────────────────────────────────────────────────────
  Widget _buildCinField() {
    final bool cinOk = _cinValid;

    return AnimatedBuilder(
      animation: _cinShakeAnim,
      builder: (_, child) {
        final shake = math.sin(_cinShakeAnim.value * math.pi * 5) * 8 * (1 - _cinShakeAnim.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('CIN DE L\'OPÉRATEUR', '1'),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _cinHasFocus ? _cyan.withOpacity(0.07) : _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _cinError != null
                    ? _red.withOpacity(0.7)
                    : _cinHasFocus
                        ? _cyan.withOpacity(0.7)
                        : _cyan.withOpacity(0.2),
                width: _cinHasFocus || _cinError != null ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: _cinCtrl,
              focusNode: _cinFocus,
              keyboardType: TextInputType.number,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 22,
                letterSpacing: 4,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '_ _ _ _ _ _ _ _',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.15),
                  fontSize: 20,
                  letterSpacing: 6,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    Icons.badge_rounded,
                    color: _cinError != null
                        ? _red.withOpacity(0.7)
                        : _cyan.withOpacity(0.5),
                    size: 22,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: cinOk
                        ? Icon(Icons.check_circle_rounded,
                            key: const ValueKey('ok'),
                            color: const Color(0xFF69F0AE), size: 22)
                        : _cinCtrl.text.isNotEmpty
                            ? Icon(Icons.error_outline_rounded,
                                key: const ValueKey('err'),
                                color: _red.withOpacity(0.6), size: 22)
                            : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),
              ),
            ),
          ),
          // Message d'erreur
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _cinError != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: _red.withOpacity(0.7), size: 13),
                        const SizedBox(width: 4),
                        Text(
                          _cinError!,
                          style: TextStyle(
                              color: _red.withOpacity(0.7), fontSize: 11),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Compteur de chiffres
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_cinCtrl.text.length}/8 chiffres',
                style: TextStyle(
                  color: cinOk
                      ? const Color(0xFF69F0AE).withOpacity(0.7)
                      : Colors.white.withOpacity(0.2),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _red.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: _red, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_apiError!,
                  style: TextStyle(color: _red, fontSize: 12)),
            ),
          ],
        ),
      );

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cyan.withOpacity(0.25)),
              ),
              child: Icon(Icons.arrow_back_ios_rounded, color: _cyan, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NOUVELLE MISSION',
                  style: TextStyle(color: _cyan, fontWeight: FontWeight.bold,
                      fontSize: 20, letterSpacing: 2.5)),
              Text('Déploiement rapide',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.35), fontSize: 12)),
            ],
          ),
          const Spacer(),
          _buildProgressDots(),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    final steps = [
      _cinValid,                          // ✅ étape CIN
      _nameCtrl.text.trim().isNotEmpty,
      _selectedType != null,
    ];
    return Row(
      children: List.generate(steps.length, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(left: 6),
        width: steps[i] ? 20 : 8, height: 8,
        decoration: BoxDecoration(
          color: steps[i] ? _cyan : _cyan.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: steps[i]
              ? [BoxShadow(color: _cyan.withOpacity(0.4), blurRadius: 6)]
              : [],
        ),
      )),
    );
  }

  Widget _buildNameField() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) {
        final shake = math.sin(_shakeAnim.value * math.pi * 5) * 8 * (1 - _shakeAnim.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('NOM DE LA MISSION', '2'), // ✅ était "1"
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _nameHasFocus ? _cyan.withOpacity(0.07) : _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _nameHasFocus ? _cyan.withOpacity(0.7) : _cyan.withOpacity(0.2),
                width: _nameHasFocus ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: _nameCtrl,
              focusNode: _nameFocus,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Ex: Immeuble Rue Centrale...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.drive_file_rename_outline_rounded,
                      color: _cyan.withOpacity(0.5), size: 20),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: _nameCtrl.text.trim().isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.check_circle_rounded, color: _cyan, size: 20),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneBadge() {
    final bool hasRealLocation = _locationResult != null &&
        _locationResult!.ok &&
        _locationResult!.place != 'AUTO';

    final Color locationColor = _locationLoading
        ? _cyan.withOpacity(0.5)
        : hasRealLocation
            ? const Color(0xFF69F0AE)
            : _red.withOpacity(0.8);

    final IconData locationIcon = _locationLoading
        ? Icons.gps_not_fixed_rounded
        : hasRealLocation
            ? Icons.location_on_rounded
            : Icons.location_off_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('POSITION DE L\'OPÉRATEUR', '3'), // ✅ était "2"
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: locationColor.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: locationColor.withOpacity(0.12),
                  border: Border.all(color: locationColor.withOpacity(0.4)),
                ),
                child: _locationLoading
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2, color: _cyan),
                      )
                    : Icon(locationIcon, color: locationColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationLoading ? 'Localisation en cours...'
                          : hasRealLocation ? 'Position détectée'
                          : 'GPS indisponible',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _locationLoading ? 'Recherche du signal GPS...'
                          : _locationResult?.place ?? 'AUTO',
                      style: TextStyle(
                          color: locationColor,
                          fontSize: 11,
                          fontWeight: _locationLoading ? FontWeight.normal : FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: locationColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: locationColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      _locationLoading ? 'GPS...'
                          : hasRealLocation ? 'DÉTECTÉ' : 'ERREUR',
                      style: TextStyle(
                          color: locationColor, fontSize: 9,
                          fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  if (!_locationLoading && !hasRealLocation) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _loadLocation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _cyan.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _cyan.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, color: _cyan, size: 11),
                            const SizedBox(width: 3),
                            Text('RÉESSAYER',
                                style: TextStyle(
                                    color: _cyan, fontSize: 8,
                                    fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('TYPE DE MISSION', '4'), // ✅ était "3"
        const SizedBox(height: 14),
        ...List.generate(_types.length, (i) => _buildTypeCard(i)),
      ],
    );
  }

  Widget _buildTypeCard(int i) {
    final (type, icon, label, desc, color) = _types[i];
    final selected = _selectedType == type;
    return GestureDetector(
      onTapDown: (_) => _cardCtrl[i].forward(),
      onTapUp: (_) => _selectType(i),
      onTapCancel: () => _cardCtrl[i].reverse(),
      child: AnimatedBuilder(
        animation: _cardScale[i],
        builder: (_, child) =>
            Transform.scale(scale: _cardScale[i].value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.08) : _cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color.withOpacity(0.7) : _cyan.withOpacity(0.12),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [BoxShadow(color: color.withOpacity(0.18), blurRadius: 20)]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? color.withOpacity(0.18) : Colors.white.withOpacity(0.04),
                  border: Border.all(
                      color: selected ? color.withOpacity(0.5) : Colors.transparent),
                ),
                child: Icon(icon,
                    color: selected ? color : Colors.white.withOpacity(0.25),
                    size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(
                        color: selected ? color : Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                    const SizedBox(height: 3),
                    Text(desc, style: TextStyle(
                        color: Colors.white.withOpacity(selected ? 0.5 : 0.25),
                        fontSize: 11)),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? color : Colors.transparent,
                  border: Border.all(
                      color: selected ? color : Colors.white.withOpacity(0.12),
                      width: 1.5),
                ),
                child: selected
                    ? Icon(Icons.check_rounded,
                        color: const Color(0xFF07111E), size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaunchBtn() {
    return GestureDetector(
      onTap: _launch,
      child: _canLaunch
          ? AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) =>
                  Transform.scale(scale: _pulseAnim.value, child: child),
              child: _launchBtnContent(true),
            )
          : _launchBtnContent(false),
    );
  }

  Widget _launchBtnContent(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(colors: [Color(0xFF00B8D4), Color(0xFF00E5FF)])
            : null,
        color: active ? null : _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: active ? _cyan : _cyan.withOpacity(0.1), width: 1.5),
        boxShadow: active
            ? [BoxShadow(color: _cyan.withOpacity(0.35), blurRadius: 24)]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rocket_launch_rounded,
              color: active ? const Color(0xFF07111E) : _cyan.withOpacity(0.2),
              size: 22),
          const SizedBox(width: 12),
          Text(
            active ? 'DÉPLOYER LE ROBOT' : 'REMPLIR LES CHAMPS',
            style: TextStyle(
                color: active ? const Color(0xFF07111E) : _cyan.withOpacity(0.2),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchOverlay() {
    return AnimatedBuilder(
      animation: _launchAnim,
      builder: (_, __) => Opacity(
        opacity: _launchAnim.value,
        child: Container(
          color: _bg.withOpacity(0.94),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 110, height: 110,
                  child: AnimatedBuilder(
                    animation: _radarCtrl,
                    builder: (_, __) => CustomPaint(
                        painter: _RadarPainter(_radarCtrl.value)),
                  ),
                ),
                const SizedBox(height: 28),
                Text('MISSION CRÉÉE',
                    style: TextStyle(
                        color: _cyan, fontWeight: FontWeight.bold,
                        letterSpacing: 4, fontSize: 20)),
                const SizedBox(height: 8),
                Text(_nameCtrl.text.trim(),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 14)),
                // ✅ CIN affiché dans l'overlay de succès
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_rounded,
                        color: _cyan.withOpacity(0.6), size: 13),
                    const SizedBox(width: 4),
                    Text('Opérateur CIN: ${_cinCtrl.text.trim()}',
                        style: TextStyle(
                            color: _cyan.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
                if (_locationResult != null && _locationResult!.ok) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: const Color(0xFF69F0AE), size: 13),
                      const SizedBox(width: 4),
                      Text(_locationResult!.place,
                          style: TextStyle(
                              color: const Color(0xFF69F0AE).withOpacity(0.8),
                              fontSize: 12)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadarDecor() {
    return Positioned(
      top: -60, right: -60,
      child: AnimatedBuilder(
        animation: _radarCtrl,
        builder: (_, __) => Opacity(
          opacity: 0.05,
          child: SizedBox(
            width: 260, height: 260,
            child: CustomPaint(painter: _RadarBgPainter(_radarCtrl.value)),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, String step) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _cyan.withOpacity(0.12),
            border: Border.all(color: _cyan.withOpacity(0.4)),
          ),
          child: Center(
            child: Text(step,
                style: TextStyle(
                    color: _cyan, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
      ],
    );
  }
}

// ─── Painters (inchangés) ──────────────────────────────────────────────────────
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
          p..color = const Color(0xFF00E5FF).withOpacity(0.6));
    }
    canvas.drawCircle(c, r,
        Paint()
          ..shader = SweepGradient(
            startAngle: -math.pi / 2 + t * 2 * math.pi,
            endAngle:   -math.pi / 2 + t * 2 * math.pi + math.pi / 2,
            colors: [Colors.transparent, const Color(0xFF00E5FF)],
          ).createShader(Rect.fromCircle(center: c, radius: r))
          ..style = PaintingStyle.fill);
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
      -math.pi / 2 + t * 2 * math.pi, math.pi / 2, true,
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