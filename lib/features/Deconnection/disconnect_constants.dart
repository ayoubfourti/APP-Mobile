import 'package:flutter/material.dart';

class DisconnectConstants {
  static const Color red  = Color(0xFFFF3232);
  static const Color cyan = Color(0xFF00F5FF);
  static const Color bg   = Color(0xFF060006);

  static const List<String> messages = [
    "INITIATING DISCONNECT...",
    "TERMINATING ROS BRIDGE...",
    "CLOSING WEBSOCKET...",
    "FLUSHING BUFFERS...",
    "CLEARING TOPIC LIST...",
    "SYSTEM OFFLINE",
  ];
}