// lib/features/mission/data/mission_state.dart
import 'package:flutter/material.dart';
import '../presentation/models/mission_model.dart';
import 'mission_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../robot_connection/data/robot_repository.dart';
import '../../robot_connection/data/robot_session.dart';
import '../../../core/services/victim_service.dart';

class MissionState extends ChangeNotifier {
  MissionState._();
  static final MissionState instance = MissionState._();

  MissionModel? _sessionMission;
  MissionModel? get sessionMission => _sessionMission;

  void setSessionMission(MissionModel? mission) {
    _sessionMission = mission;
    notifyListeners();
  }

  List<MissionModel> _missions = [];
  bool               _loading  = false;
  String?            _error;

  List<MissionModel> get missions => List.unmodifiable(_missions);
  bool               get loading  => _loading;
  String?            get error    => _error;

  MissionModel? get activeMission {
    try {
      return _missions.firstWhere((m) => m.status == MissionStatus.active);
    } catch (_) {
      return null;
    }
  }

  List<MissionModel> get history => _missions
      .where((m) => m.status != MissionStatus.active)
      .toList()
      .reversed
      .toList();

  Future<void> loadMissions() async {
    _loading = true;
    _error   = null;
    notifyListeners();

    final result = await MissionRepository.fetchAll();

    if (result.ok && result.data != null) {
      _missions = result.data!;
      _error    = null;
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> createMission({
    required String name,
    required MissionType type,
    required int operatorCin,
    String zone = 'AUTO',
  }) async {
    final location = await LocationService.getLocation();

    final result = await MissionRepository.create(
      name:        name,
      type:        type,
      operatorCin: operatorCin,
      zone:        zone,
      place:       location.place,
      latitude:    location.latitude,
      longitude:   location.longitude,
    );

    if (result.ok && result.data != null) {
      final mission = result.data!;
      _missions.add(mission);
      notifyListeners();

      // ✅ Affecter automatiquement le robot connecté
      final robotId = RobotSession.instance.robotId;
      if (robotId != null) {
        await RobotRepository.assignToMission(
          robotId:   robotId,
          missionId: mission.dbId,
        );
      }
      VictimService.instance.reset();
      MissionRepository.clearLog(); // ✅ Nettoie le log au démarrage de mission
      return null;
    }
    return result.error ?? 'Erreur création';
  }

  Future<String?> completeMission(int dbId) async {
    final result = await MissionRepository.complete(dbId);
    if (result.ok && result.data != null) {
      _updateLocal(result.data!);
      if (_sessionMission?.dbId == dbId) _sessionMission = null;
      MissionRepository.clearLog(); // ✅ Nettoie le log après sauvegarde en BD
      return null;
    }
    return result.error ?? 'Erreur';
  }

  Future<String?> abortMission(int dbId) async {
    final result = await MissionRepository.abort(dbId);
    if (result.ok && result.data != null) {
      _updateLocal(result.data!);
      if (_sessionMission?.dbId == dbId) _sessionMission = null;
      MissionRepository.clearLog(); // ✅ Nettoie le log après sauvegarde en BD
      return null;
    }
    return result.error ?? 'Erreur';
  }

  Future<String?> deleteMission(int dbId) async {
    final result = await MissionRepository.delete(dbId);
    if (result.ok) {
      _missions.removeWhere((m) => m.dbId == dbId);
      notifyListeners();
      return null;
    }
    return result.error ?? 'Erreur suppression';
  }

  void _updateLocal(MissionModel updated) {
    final idx = _missions.indexWhere((m) => m.dbId == updated.dbId);
    if (idx != -1) _missions[idx] = updated;
    notifyListeners();
  }
}