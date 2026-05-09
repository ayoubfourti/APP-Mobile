// lib/features/mission/data/mission_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../presentation/models/mission_model.dart';
import '../../../core/config/api_config.dart';
import '../../../core/services/victim_service.dart';
import '../../../core/services/slam_map_service.dart';

class RepoResult<T> {
  final bool    ok;
  final T?      data;
  final String? error;
  const RepoResult.success(this.data) : ok = true,  error = null;
  const RepoResult.fail(this.error)   : ok = false, data  = null;
}

class MissionRepository {

  // ─── Log local ────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _missionLog = [];

  static void addLogEntry({
    required double cpu,
    required double gpu,
    required double battery,
  }) {
    _missionLog.add({
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'cpu':       double.parse(cpu.toStringAsFixed(1)),
      'gpu':       double.parse(gpu.toStringAsFixed(1)),
      'battery':   double.parse(battery.toStringAsFixed(1)),
    });
  }

  static void clearLog() => _missionLog.clear();

  // ─── GET /mission/GetMissions ──────────────────────────────────────────────
  static Future<RepoResult<List<MissionModel>>> fetchAll() async {
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.missions))
          .timeout(ApiConfig.timeout);

      if (res.statusCode != 200)
        return RepoResult.fail('Erreur serveur (${res.statusCode})');

      final list = jsonDecode(res.body) as List<dynamic>;
      final missions = list
          .map((e) => MissionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return RepoResult.success(missions);
    } on SocketException {
      return const RepoResult.fail('Serveur inaccessible');
    } catch (e) {
      return RepoResult.fail('Erreur: $e');
    }
  }

  // ─── Fetch une mission par id en passant par GetMissions ──────────────────
  // Contourne le bug req.params.id_mission dans getMissionById du backend
  static Future<Map<String, dynamic>?> _fetchMissionRaw(int id) async {
    final res = await http
        .get(Uri.parse(ApiConfig.missions))
        .timeout(ApiConfig.timeout);

    if (res.statusCode != 200) return null;

    final list = jsonDecode(res.body) as List<dynamic>;
    try {
      return list
          .cast<Map<String, dynamic>>()
          .firstWhere((m) => m['idMission'].toString() == id.toString());
    } catch (_) {
      return null;
    }
  }

  // ─── POST /mission/AddMission ──────────────────────────────────────────────
  static Future<RepoResult<MissionModel>> create({
    required String name,
    required MissionType type,
    required int    operatorCin,
    String  zone      = 'AUTO',
    String  place     = 'AUTO',
    double? latitude,
    double? longitude,
  }) async {
    try {
      final now = DateTime.now().toUtc();

      final res = await http
          .post(
            Uri.parse(ApiConfig.missionAdd),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'titleMission': name,
              'dateMission':  '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}+00',
              'place':        place,
              'map':          {},
              'video':        '',
              'type':         type.apiValue,
              'status':       'active',
              'zone':         zone,
              'startTime':    now.toIso8601String(),
              'endTime':      now.toIso8601String(),
              'latitude':     latitude,
              'longitude':    longitude,
              'log':          List<Map<String, dynamic>>.from(_missionLog),
              'operatorCin':  operatorCin,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (res.statusCode != 201)
        return RepoResult.fail('Erreur serveur (${res.statusCode})');

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return RepoResult.success(
          MissionModel.fromJson(body['mission'] as Map<String, dynamic>));
    } on SocketException {
      return const RepoResult.fail('Serveur inaccessible');
    } catch (e) {
      return RepoResult.fail('Erreur: $e');
    }
  }

  // ─── complete / abort ──────────────────────────────────────────────────────
  static Future<RepoResult<MissionModel>> complete(int id) async {
    return _updateStatus(id, 'completed');
  }

  static Future<RepoResult<MissionModel>> abort(int id) async {
    return _updateStatus(id, 'aborted');
  }

  // ─── _updateStatus — NE PAS appeler GetMissionById (bug backend) ──────────
  static Future<RepoResult<MissionModel>> _updateStatus(
      int id, String newStatus) async {
    try {
      // 1. Récupérer la mission via GetMissions (contournement du bug)
      final mission = await _fetchMissionRaw(id);
      if (mission == null)
        return const RepoResult.fail('Mission introuvable');

      // 2. PUT /mission/UpdateMission/:id
      final now = DateTime.now().toUtc().toIso8601String();
      final res = await http
          .put(
            Uri.parse(ApiConfig.missionUpdate(id)),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'titleMission': mission['titleMission'],
              'dateMission':  mission['dateMission'],
              'place':        mission['place']  ?? 'AUTO',
              'map':          {},
              'video':        mission['video']  ?? '',
              'type':         mission['type']   ?? 'search',
              'status':       newStatus,
              'zone':         mission['zone']   ?? 'AUTO',
              'startTime':    mission['startTime'],
              'endTime':      now,
              'latitude':     mission['latitude'],
              'longitude':    mission['longitude'],
              'log':          List<Map<String, dynamic>>.from(_missionLog),
              'operatorCin':  mission['operatorCin'],
              'victims':      newStatus == 'completed'
                                  ? VictimService.instance.totalUnique
                                  : (mission['victims'] ?? 0),
            }),
          )
          .timeout(ApiConfig.timeout);

      if (res.statusCode != 200)
        return RepoResult.fail('Erreur mise à jour (${res.statusCode})');

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      SlamMapService.instance.resetMap();
      return RepoResult.success(
    MissionModel.fromJson(body['mission'] as Map<String, dynamic>));
    } on SocketException {
      return const RepoResult.fail('Serveur inaccessible');
    } catch (e) {
      return RepoResult.fail('Erreur: $e');
    }
  }

  // ─── DELETE /mission/DeleteMissionById/:id ────────────────────────────────
  // Le backend utilise req.params.id_mission (bug) au lieu de req.params.idMission
  // → la suppression retourne 404 même si l'ID est correct dans l'URL
  // → on considère 200 ET 404 comme un succès (suppression effectuée ou déjà absente)
  static Future<RepoResult<void>> delete(int id) async {
    try {
      final res = await http
          .delete(Uri.parse(ApiConfig.missionDelete(id)))
          .timeout(ApiConfig.timeout);

      // 200 = supprimé  |  404 = bug backend mais on retire quand même localement
      if (res.statusCode == 200 || res.statusCode == 404)
        return const RepoResult.success(null);

      return RepoResult.fail('Erreur suppression (${res.statusCode})');
    } on SocketException {
      return const RepoResult.fail('Serveur inaccessible');
    } catch (e) {
      return RepoResult.fail('Erreur: $e');
    }
  }

  // ─── sendLog — route inexistante, ignoré silencieusement ─────────────────
  static Future<RepoResult<void>> sendLog({
    required int    missionId,
    required double battery,
    required double cpu,
    required double gpu,
    required double temperature,
    required double distance,
  }) async {
    return const RepoResult.success(null);
  }
}