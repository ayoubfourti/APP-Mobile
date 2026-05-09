// lib/features/robot_connection/data/robot_repository.dart

import 'package:projectpi/features/sensor_monitor/presentation/state/sensor_state.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/services/rosbridge_service.dart';

class RobotResult {
  final bool                  ok;
  final Map<String, dynamic>? data;
  final String?               error;
  const RobotResult.success(this.data) : ok = true,  error = null;
  const RobotResult.fail(this.error)   : ok = false, data  = null;
}

class RobotRepository {

  // ─── Chercher robot par IP + Port ────────────────────────────────────────
  // Le nouveau serveur n'a pas de route /connect
  // On récupère tous les robots et on filtre par ip_address + port
  static Future<RobotResult> findByIpPort({
    required String ip,
    required int    port,
  }) async {
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.robotConnect))
          .timeout(ApiConfig.timeout);

      if (res.statusCode != 200) {
        return RobotResult.fail('Erreur serveur (${res.statusCode})');
      }

      // Le serveur retourne un tableau direct : [ {...}, {...} ]
      final list = jsonDecode(res.body) as List<dynamic>;

      // Filtrer par ip_address et port
      final matches = list
          .cast<Map<String, dynamic>>()
          .where((r) =>
              r['ip_address'] == ip &&
              r['port'].toString() == port.toString())
          .toList();

      if (matches.isEmpty)
        return const RobotResult.fail('Robot introuvable avec cette IP/port');

      final robot = matches.first;

      // Connecter rosbridge
      RosbridgeService().connect(ApiConfig.jetsonIp, ApiConfig.rosBridgePort);
      SensorState.instance.reattachToWebSocket();

      return RobotResult.success(robot);
    } on SocketException {
      return const RobotResult.fail('Serveur inaccessible');
    } catch (e) {
      return RobotResult.fail('Erreur: $e');
    }
  }

  // ─── Affecter robot à mission ─────────────────────────────────────────────
  static Future<RobotResult> assignToMission({
    required int robotId,
    required int missionId,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(ApiConfig.robotMission),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'robotId':   robotId,
              'missionId': missionId,
            }),
          )
          .timeout(ApiConfig.timeout);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201 && body['success'] == true) {
        return RobotResult.success(null);
      }
      return RobotResult.fail(body['message'] as String? ?? 'Erreur affectation');
    } on SocketException {
      return const RobotResult.fail('Serveur inaccessible');
    } catch (e) {
      return RobotResult.fail('Erreur: $e');
    }
  }

  // ─── Déconnexion rosbridge ────────────────────────────────────────────────
  static void disconnect() {
    RosbridgeService().disconnect();
  }
}