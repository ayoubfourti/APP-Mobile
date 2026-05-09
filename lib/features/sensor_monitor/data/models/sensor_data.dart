/// Modèle représentant les données des capteurs
class SensorData {
  final double distance;
  final double battery;
  final double temperature;
  final double imu;
  final bool cameraActive;
  final double cpuUsage;
  final double gpuUsage;

  const SensorData({
    required this.distance,
    required this.battery,
    required this.temperature,
    required this.imu,
    required this.cameraActive,
    required this.cpuUsage,
    required this.gpuUsage,
  });

  /// Valeurs par défaut
  factory SensorData.initial() {
    return const SensorData(
      distance: 0.0,
      battery: 0.0,
      temperature: 0.0,
      imu: 0.0,
      cameraActive: false,
      cpuUsage: 0.0,
      gpuUsage: 0.0,
    );
  }

  /// Copie avec modification
  SensorData copyWith({
    double? distance,
    double? battery,
    double? temperature,
    double? imu,
    bool? cameraActive,
    double? cpuUsage,
    double? gpuUsage,
  }) {
    return SensorData(
      distance: distance ?? this.distance,
      battery: battery ?? this.battery,
      temperature: temperature ?? this.temperature,
      imu: imu ?? this.imu,
      cameraActive: cameraActive ?? this.cameraActive,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      gpuUsage: gpuUsage ?? this.gpuUsage,
    );
  }
}