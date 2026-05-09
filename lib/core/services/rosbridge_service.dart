import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RosbridgeService {
  static final RosbridgeService _instance = RosbridgeService._internal();
  factory RosbridgeService() => _instance;
  RosbridgeService._internal();

  WebSocketChannel? _channel;
  bool _connected = false;
  bool get isConnected => _connected;
  WebSocketChannel? get channel => _channel;

  final _streamController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get messages => _streamController.stream;

  Function(double)? onBattery;
  Function(bool)? onGas;

  Future<void> connect(String ip, int port) async {
    try {
      debugPrint('🔌 Connexion à ws://$ip:$port...');
      _channel = WebSocketChannel.connect(Uri.parse('ws://$ip:$port'));
      await _channel!.ready;
      _connected = true;
      debugPrint('✅ Connecté !');

      _channel!.stream.listen(
        (message) {
          _streamController.add(message);
          try {
            // Gérer stats Jetson {"type": "stats", "data": {...}}
            final data = jsonDecode(message);
            if (data['type'] == 'stats' && data['data'] != null) {
              final d = data['data'];
              if (onBattery != null && d['battery'] != null) {
                onBattery?.call((d['battery'] as num).toDouble());
              }
            }
            if (data['type'] == 'gaz') {
              final bool alert = data['alert'] == true;
              onGas?.call(alert);
              }
          } catch (_) {}
        },
        onDone: () {
          _connected = false;
          debugPrint('❌ Connexion fermée');
        },
        onError: (e) {
          _connected = false;
          debugPrint('❌ Erreur: $e');
        },
      );
    } catch (e) {
      _connected = false;
      debugPrint('❌ Erreur connexion: $e');
    }
  }

  // ✅ Envoyer juste la commande directe "forward", "stop", etc.
  void sendCommand(String command) {
    if (!_connected || _channel == null) {
      debugPrint('⚠️ Non connecté !');
      return;
    }
    _channel!.sink.add(command);
    debugPrint('📤 $command');
  }

  void disconnect() {
    _channel?.sink.close();
    _connected = false;
  }
}
