// features/sensor_monitor/domain/services/jetson_sensor_service.dart
import 'dart:convert';
import '../../data/models/sensor_data.dart';
import '../../../../core/services/rosbridge_service.dart';

/// Écoute les stats Jetson publiées par le WebSocket bridge ROS2
/// et les convertit en SensorData pour le SensorState.
class JetsonSensorService {
  final RosbridgeService _rosbridge = RosbridgeService();

  Function(SensorData)? onDataUpdate;

  void start() {
    // On se branche sur le stream du WebSocket déjà connecté
    _rosbridge.messages.listen(
      _onMessage,
      onError: (_) {},
      cancelOnError: false,
    );
  }

  void _onMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;

      // On filtre uniquement les messages de stats Jetson
      if (json['type'] != 'stats') return;

      final d = json['data'] as Map<String, dynamic>;

      final data = SensorData(
        cpuUsage:    (d['cpu']         as num).toDouble(),
        gpuUsage:    (d['gpu']         as num).toDouble(),
        temperature: (d['temperature'] as num).toDouble(),
        battery:     (d['battery']     as num).toDouble(),
        // Ces champs n'ont pas d'équivalent Jetson pour l'instant
        // → on les garde à 0 / true en attendant d'autres topics ROS2
        distance:    0.0,
        imu:         0.0,
        cameraActive: true,
      );

      onDataUpdate?.call(data);
    } catch (_) {
      // Message "OK:cmd" ou autre format → ignoré silencieusement
    }
  }

  void dispose() {
    // Pas besoin de fermer — RosbridgeService gère la connexion

  }
}