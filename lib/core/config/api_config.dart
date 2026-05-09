// lib/core/config/api_config.dart

class ApiConfig {
  // ─── Jetson hostname (mDNS) ───────────────────────────────────────────────
  static const String _jetsonHost = 'hexapod.local'; 

  // ─── Ports ────────────────────────────────────────────────────────────────
  static const int _cameraPort    = 8080;
  static const int _rosBridgePort = 9090;



  // ─── Base URL ─────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://hexapod-backend.onrender.com';

  // ─── Robots ───────────────────────────────────────────────────────────────
  static String get robots       => '$baseUrl/robot/GetRobots';
  static String get robotConnect => '$baseUrl/robot/GetRobots';
  static String robot(int id)    => '$baseUrl/robot/GetRobotById/$id';
  static String get robotMission => '$baseUrl/robot-mission';

  // ─── Missions ─────────────────────────────────────────────────────────────
  static String get missions            => '$baseUrl/mission/GetMissions';
  static String get missionAdd          => '$baseUrl/mission/AddMission';
  static String mission(int id)         => '$baseUrl/mission/GetMissionById/$id';
  static String missionDelete(int id)   => '$baseUrl/mission/DeleteMissionById/$id';
  static String missionUpdate(int id)   => '$baseUrl/mission/UpdateMission/$id';
  static String missionComplete(int id) => '$baseUrl/mission/UpdateMission/$id';
  static String missionAbort(int id)    => '$baseUrl/mission/UpdateMission/$id';
  static String missionLog(int id)      => '$baseUrl/mission/UpdateMission/$id';

  // ─── Jetson (mDNS) ────────────────────────────────────────────────────────
  static String get cameraStreamUrl => 'http://$_jetsonHost:$_cameraPort/stream';
  static String get rosBridgeUrl    => 'ws://$_jetsonHost:$_rosBridgePort';
  static String get jetsonIp        => _jetsonHost; // retourne hexapod.local
  static int    get rosBridgePort   => _rosBridgePort;

  // ─── Timeout ──────────────────────────────────────────────────────────────
  static const Duration timeout = Duration(seconds: 8);
}