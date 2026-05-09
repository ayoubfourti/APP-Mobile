import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/sensor_data.dart';
import '../../domain/services/jetson_sensor_service.dart';

class SensorState extends ChangeNotifier {
  SensorState._() {
    _initializeSensor();
  }
  static final SensorState instance = SensorState._();

  SensorData _currentData = SensorData.initial();
  final _sensor = JetsonSensorService();

  SensorData get currentData => _currentData;

  void _initializeSensor() {
    _sensor.onDataUpdate = (data) {
      _currentData = data;
      notifyListeners();
    };
    _sensor.start();
  }

  void reattachToWebSocket() {
    _sensor.dispose();
    _sensor.onDataUpdate = (data) {
      _currentData = data;
      notifyListeners();
    };
    _sensor.start();
  }

  void stopSimulation() {
    _sensor.dispose();
  }
}