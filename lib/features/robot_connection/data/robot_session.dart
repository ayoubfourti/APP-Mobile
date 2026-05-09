class RobotSession {
  RobotSession._();
  static final RobotSession instance = RobotSession._();

  int?    robotId;
  String? robotName;
  String? ipAddress;
  int?    port;

  void set({
    required int    id,
    required String name,
    required String ip,
    required int    port,
  }) {
    robotId   = id;
    robotName = name;
    ipAddress = ip;
    this.port = port;
  }

  void clear() {
    robotId   = null;
    robotName = null;
    ipAddress = null;
    port      = null;
  }

  bool get isConnected => robotId != null;
}