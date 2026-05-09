// lib/core/services/victim_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'rosbridge_service.dart';
import 'notification_service.dart';
import 'package:flutter/material.dart';

class VictimService extends ChangeNotifier {
  VictimService._();
  static final VictimService instance = VictimService._();

  // Déduplication par victim_id
  final Set<int> _seenIds = {};
  int _totalUnique = 0;
  int get totalUnique => _totalUnique;

  bool _listening = false;

  void start() {
  if (_listening) return;
  _listening = true;

  RosbridgeService().messages.listen(
    _onMessage,
    onError: (_) {},
    cancelOnError: false,
  );

  // Attendre que le WebSocket soit connecté avant de s'abonner
  _subscribeWhenReady();
  debugPrint('🎯 [VictimService] Démarré');
}

void _subscribeWhenReady() async {
  for (int i = 0; i < 30; i++) {
    await Future.delayed(const Duration(seconds: 1));
    if (RosbridgeService().isConnected) {
      debugPrint('🎯 [VictimService] Prêt à recevoir les victimes');
      return;
    }
    debugPrint('⏳ [VictimService] Attente connexion... ($i)');
  }
}

  void reset() {
    _seenIds.clear();
    _totalUnique = 0;
  }

  void _onMessage(dynamic raw) {
  try {
    // Ignorer "OK:..." (confirmation subscribe)
    if ((raw as String).startsWith('OK:')) return;

    final json = jsonDecode(raw) as Map<String, dynamic>;

    // Format stats Jetson → ignorer
    if (json['type'] == 'stats') return;

    // Format direct: {"event": "heartbeat", ...} ou {"event": "victim_confirmed", ...}
    final event = json['event'] as String?;
    if (event == null) return;

    debugPrint('📨 [VictimService] event: $event');

    switch (event) {
      case 'victim_confirmed':
        _handleVictim(json);
        break;
      case 'heartbeat':
        _totalUnique = (json['victims_total_unique'] as num?)?.toInt() ?? _totalUnique;
        notifyListeners();
        break;
      case 'mission_summary':
        _totalUnique = (json['total_unique_victims'] as num?)?.toInt() ?? _totalUnique;
        notifyListeners();
        break;
      case 'publisher_started':
        reset();
        notifyListeners();
        debugPrint('🎯 [VictimService] Nouvelle mission démarrée');
        break;
    }
  } catch (e) {
    // ignore
  }
}

  void _handleVictim(Map<String, dynamic> json) {
    final victimId   = (json['victim_id']   as num).toInt();
    final confidence = (json['confidence']  as num).toDouble();

    // Déduplication
    if (_seenIds.contains(victimId)) return;
    _seenIds.add(victimId);
    _totalUnique = _seenIds.length;
     notifyListeners();
    debugPrint('🚨 [VictimService] Victime #$victimId — confiance ${(confidence * 100).toStringAsFixed(0)}%');

    // Notification push
    NotificationService.instance.showVictimAlert(
      victimId:   victimId,
      confidence: confidence,
    );
  }
}