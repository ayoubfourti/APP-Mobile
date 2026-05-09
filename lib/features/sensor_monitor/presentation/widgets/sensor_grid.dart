import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/sensor_data.dart';
import 'lidar_card.dart';
import 'compass_card.dart';
import 'battery_card.dart';
import 'arc_gauge_card.dart';
import 'temperature_card.dart';
import 'camera_card.dart';

/// Grid contenant toutes les cartes de capteurs
class SensorGrid extends StatelessWidget {
  final SensorData data;
  final Animation<double> radarAnim;
  final Animation<double> pulseAnim;
  final Animation<double> cameraBlinkAnim;
  final Animation<double> glowAnim;

  const SensorGrid({
    super.key,
    required this.data,
    required this.radarAnim,
    required this.pulseAnim,
    required this.cameraBlinkAnim,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Lidar + Compass
          Row(
            children: [
              Expanded(
                child: LidarCard(
                  distance: data.distance,
                  radarAnim: radarAnim,
                  glowAnim: glowAnim,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CompassCard(
                  imu: data.imu,
                  glowAnim: glowAnim,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Battery
          BatteryCard(
            battery: data.battery,
            color: _getBatteryColor(data.battery),
            pulseAnim: pulseAnim,
            glowAnim: glowAnim,
          ),
          
          const SizedBox(height: 12),
          
          // CPU + GPU
          Row(
            children: [
              Expanded(
                child: ArcGaugeCard(
                  label: 'CPU USAGE',
                  value: data.cpuUsage,
                  icon: Icons.memory_rounded,
                  color: AppColors.cyan,
                  unit: '%',
                  glowAnim: glowAnim,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ArcGaugeCard(
                  label: 'GPU USAGE',
                  value: data.gpuUsage,
                  icon: Icons.display_settings_rounded,
                  color: AppColors.purple,
                  unit: '%',
                  glowAnim: glowAnim,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Temperature
          TemperatureCard(
            temperature: data.temperature,
            color: _getTemperatureColor(data.temperature),
            glowAnim: glowAnim,
          ),
          
          const SizedBox(height: 12),
          
          // Camera
          CameraCard(
            cameraActive: data.cameraActive,
            cameraBlink: cameraBlinkAnim,
            glowAnim: glowAnim,
          ),
          
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Color _getBatteryColor(double battery) {
    if (battery < 30) return AppColors.red;
    if (battery < 60) return AppColors.orange;
    return AppColors.green;
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature > 80) return AppColors.red;
    if (temperature > 65) return AppColors.orange;
    return AppColors.cyan;
  }
}