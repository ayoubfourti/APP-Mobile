// lib/features/mission/data/mission_log_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'mission_repository.dart';
import 'mission_state.dart';
import '../../sensor_monitor/presentation/state/sensor_state.dart'; // ✅ singleton

class MissionLogService {
  MissionLogService._();
  static final MissionLogService instance = MissionLogService._();

  Timer? _timer;
  bool   _running = false;

  /// Démarre l'envoi automatique toutes les 60 secondes.
  /// À appeler quand on entre dans ControlRobotPage.
  void start() {
    if (_running) return;
    _running = true;

    // Premier envoi immédiat
    _sendLog();

    // Puis toutes les 60 secondes
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _sendLog());
    debugPrint('🟢 [LogService] Démarré');
  }

  /// Arrête le timer.
  /// À appeler dans dispose() de ControlRobotPage.
  void stop() {
    _timer?.cancel();
    _timer   = null;
    _running = false;
    debugPrint('🔴 [LogService] Arrêté');
  }

  bool get isRunning => _running;

  Future<void> _sendLog() async {
    // 1. Vérifie qu'une session mission est active
    final mission = MissionState.instance.sessionMission;
    if (mission == null) {
      debugPrint('⚠️ [LogService] Pas de sessionMission — skip');
      return;
    }

    // 2. Lit les valeurs courantes du SensorState singleton
    final data = SensorState.instance.currentData;

    // 3. ✅ Enregistre l'entrée dans le log local (sauvegardé en BD à la fin de mission)
    MissionRepository.addLogEntry(
      cpu:     data.cpuUsage,
      gpu:     data.gpuUsage,
      battery: data.battery,
    );
    debugPrint('📝 [LogService] Log ajouté — '
        'cpu:${data.cpuUsage.toStringAsFixed(1)}% '
        'gpu:${data.gpuUsage.toStringAsFixed(1)}% '
        'bat:${data.battery.toStringAsFixed(1)}%');

      final result = await MissionRepository.sendLog(
      missionId:   mission.dbId,
      battery:     data.battery,
      cpu:         data.cpuUsage,
      gpu:         data.gpuUsage,
      temperature: data.temperature,
      distance:    data.distance,
    );

    if (result.ok) {
      debugPrint('✅ [LogService] Log envoyé — mission #${mission.dbId} '
          '| bat:${data.battery.toStringAsFixed(1)}% '
          '| cpu:${data.cpuUsage.toStringAsFixed(1)}%');
    } else {
      debugPrint('❌ [LogService] Erreur: ${result.error}');
    }
  }
}