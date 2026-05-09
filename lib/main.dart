import 'package:flutter/material.dart';
import 'features/robot_connection/presentation/pages/connect_robot_page.dart';
import 'core/services/notification_service.dart';
import 'core/services/victim_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  VictimService.instance.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Robot Tools',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F2F8),
      ),
      home: const ConnectRobotPage(),
    );
  }
}
