import 'dart:async';
import 'dart:math' as math;
import '../../data/models/sensor_data.dart';

/// Service qui simule les données des capteurs
class SensorSimulatorService {
  final _random = math.Random();
  Timer? _simulationTimer;

  /// Callback appelé à chaque mise à jour
  Function(SensorData)? onDataUpdate;

  /// Démarre la simulation
  void start() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _generateRandomData(),
    );
  }

  /// Arrête la simulation
  void stop() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  /// Génère des données aléatoires
  void _generateRandomData() {
    final data = SensorData(
      distance: _random.nextDouble() * 5,
      battery: 45 + _random.nextDouble() * 52,
      temperature: 22 + _random.nextDouble() * 22,
      imu: _random.nextDouble() * 360,
      cameraActive: _random.nextBool() || _random.nextBool(),
      cpuUsage: 20 + _random.nextDouble() * 75,
      gpuUsage: 15 + _random.nextDouble() * 65,
    );

    onDataUpdate?.call(data);
  }

  void dispose() {
    stop();
  }
}
