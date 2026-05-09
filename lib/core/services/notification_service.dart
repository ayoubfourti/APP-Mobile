// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:ui'; 
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Demande permission Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> showVictimAlert({
    required int    victimId,
    required double confidence,
  }) async {
    await _plugin.show(
      victimId, // id unique = victimId → pas de doublon
      '🚨 Nouvelle victime détectée',
      'Victime #$victimId — Confiance ${(confidence * 100).toStringAsFixed(0)}%',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'victim_channel',
          'Alertes victimes',
          channelDescription: 'Notifications de détection de victimes',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }

Future<void> showGasAlert() async {
  await _plugin.show(
    999, // id fixe pour le gaz (remplace la notif précédente si déjà affichée)
    '☠️ Gaz détecté !',
    'Le capteur MQ-2 a détecté un gaz dangereux. Vérifiez immédiatement.',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'gas_channel',
        'Alertes gaz',
        channelDescription: 'Notifications de détection de gaz',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFFF3D3D),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    ),
  );
}


}