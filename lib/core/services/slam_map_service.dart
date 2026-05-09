// lib/core/services/slam_map_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:projectpi/core/config/api_config.dart';

class SlamMapService extends ChangeNotifier {
  static final SlamMapService instance = SlamMapService._();
  SlamMapService._();

  WebSocketChannel? _channel;
  ui.Image? currentMap;
  int _mapWidth = 0;
  int _mapHeight = 0;
  double _resolution = 0.05;
  double _originX = 0;
  double _originY = 0;
  bool _connected = false;
  int updateCount = 0;

  bool get isConnected => _connected;
  int get mapWidth => _mapWidth;
  int get mapHeight => _mapHeight;
  double get resolution => _resolution;
  double get originX => _originX;
  double get originY => _originY;

  void connect() {
  if (_connected) return;
  try {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://${ApiConfig.jetsonIp}:${ApiConfig.rosBridgePort}'),
    );
    _connected = true;
    notifyListeners();

    _channel!.stream.listen(
      _onMessage,
      onError: (_) { _connected = false; notifyListeners(); },
      onDone:  () { _connected = false; notifyListeners(); },
    );
  } catch (e) {
    _connected = false;
  }
}

  void _onMessage(dynamic raw) async {
  try {
    final json = jsonDecode(raw as String);

    // ✅ Format custom websocket_bridge.py
    // {"type":"map","width":229,"height":174,"resolution":0.05,
    //  "origin_x":-5.8,"origin_y":-2.9,"data":[-1,0,100,...]}
    if (json['type'] != 'map') return;

    final int w = json['width']  as int;
    final int h = json['height'] as int;
    if (w == 0 || h == 0) return;

    _mapWidth   = w;
    _mapHeight  = h;
    _resolution = (json['resolution'] as num).toDouble();
    _originX    = (json['origin_x']   as num).toDouble();
    _originY    = (json['origin_y']   as num).toDouble();

    final List<int> data = List<int>.from(json['data']);
    currentMap = await _buildImage(data, w, h);
    notifyListeners();

  } catch (e) {
    debugPrint('SlamMapService error: $e');
  }
}

Future<ui.Image> _buildImage(List<int> data, int width, int height) async {
  final pixels = Uint8List(width * height * 4);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final rosIdx     = (height - 1 - y) * width + x;
      final flutterIdx = y * width + x;
      final val = data[rosIdx];

      int r, g, b;
      if (val < 0)        { r = 128; g = 128; b = 128; }  // gris
      else if (val < 25)  { r = 255; g = 255; b = 255; }  // blanc
      else if (val < 65)  { final v = (255 - ((val-25)/40 * 255)).round(); r = g = b = v; }
      else                { r = 0;   g = 0;   b = 0;   }  // noir

      final idx = flutterIdx * 4;
      pixels[idx]     = r;
      pixels[idx + 1] = g;
      pixels[idx + 2] = b;
      pixels[idx + 3] = 255;
    }
  }

  final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
  final descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: width,
    height: height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();
  return frame.image;
}
  // Convertit une position robot (mètres) en pixel sur la carte
  Offset robotToMapPixel(double robotX, double robotY) {
    final px = ((robotX - _originX) / _resolution).round();
    final py = (_mapHeight - ((robotY - _originY) / _resolution).round());
    return Offset(px.toDouble(), py.toDouble());
  }

  void resetMap() {
  currentMap = null;
  _mapWidth  = 0;
  _mapHeight = 0;
  notifyListeners();
}

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _connected = false;
    notifyListeners();
  }
}