import 'package:flutter/material.dart';
import '../../../../core/services/rosbridge_service.dart';
import '../../../../core/config/api_config.dart';

class ControlState extends ChangeNotifier {
  final _ros = RosbridgeService();
  DateTime _lastSent = DateTime.now();
  bool _isAutoMode = false;

  double _joystickX = 0.0;
  double _joystickY = 0.0;

  bool   get isAutoMode  => _isAutoMode;
  bool   get isConnected => _ros.isConnected;
  double get joystickX   => _joystickX;
  double get joystickY   => _joystickY;

  // ✅ Plus de connect() ici — RosbridgeService est déjà connecté
  // depuis RobotRepository.findByIpPort()
  ControlState();

  void refreshConnection() {
    // ✅ Si déconnecté, on reconnecte avec l'IP de ApiConfig
    if (!_ros.isConnected) {
      _ros.connect(ApiConfig.jetsonIp, ApiConfig.rosBridgePort).then((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  void disconnect() {
    _ros.disconnect();
    notifyListeners();
  }

  void updateJoystick(double x, double y) {
    _joystickX = x;
    _joystickY = y;
    notifyListeners();

    final now = DateTime.now();
    if (now.difference(_lastSent).inMilliseconds < 100) return;
    _lastSent = now;

    if (_ros.isConnected && !_isAutoMode) {
      final cmd = _resolveCommand(x, y);
      if (cmd != null) _ros.sendCommand(cmd);
    }
  }

  String? _resolveCommand(double x, double y) {
    if (x.abs() < 0.2 && y.abs() < 0.2) return 'WALK 0 0 0';

    int vx = (x * 127).clamp(-127, 127).toInt();
    int vy = (y * 127).clamp(-127, 127).toInt();

    if (y < -0.5 && x.abs() < 0.3) return 'WALK ${vy.abs()} 0 0';
    if (y >  0.5 && x.abs() < 0.3) return 'WALK ${-vy.abs()} 0 0';
    if (x < -0.5 && y.abs() < 0.3) return 'WALK 0 0 ${vx.abs()}';
    if (x >  0.5 && y.abs() < 0.3) return 'WALK 0 0 ${-vx.abs()}';
    if (x < -0.5 && y < -0.3)      return 'WALK $vy $vx 0';
    if (x >  0.5 && y < -0.3)      return 'WALK $vy $vx 0';

    return null;
  }

  void resetJoystick() {
    _joystickX = 0.0;
    _joystickY = 0.0;
    notifyListeners();
    if (_ros.isConnected) _ros.sendCommand('WALK 0 0 0');
  }

  void toggleAutoMode() {
    _isAutoMode = !_isAutoMode;
    if (_isAutoMode) _ros.sendCommand('WALK 0 0 0');
    notifyListeners();
  }

  @override
  void dispose() {
    _ros.disconnect();
    super.dispose();
  }
}