// lib/features/robot_tools/data/tool_items_data.dart

import 'package:flutter/material.dart';
import '../presentation/models/tool_item.dart';
import '../presentation/pages/control_robot_wrapper.dart';
import '../../sensor_monitor/presentation/pages/sensor_monitor_page.dart';
import '../../Deconnection/presentation/pages/DisconnectAnimationPage.dart';
import '../../mission/presentation/pages/mission_list_page.dart';
import '../../mission/presentation/widget/mission_select_dialog.dart';
import '../../mission/data/mission_state.dart';

class ToolItemsData {
  static List<ToolItem> getTools(BuildContext context) {
    return [
      ToolItem(
        icon: Icons.settings_remote_rounded,
        title: "CONTROL\nROBOT",
        onTap: () => _navigateToControl(context),
      ),
      ToolItem(
        icon: Icons.assignment_rounded,
        title: "MISSION",
        onTap: () => _navigateToMission(context),
      ),
      ToolItem(
        icon: Icons.list_alt_rounded,
        title: "ROS\nLISTS",
        isEnabled: false,
      ),
      ToolItem(
        icon: Icons.sensors_rounded,
        title: "SENSOR\nMONITOR",
        onTap: () => _navigateToSensor(context),
      ),
      ToolItem(icon: Icons.map_rounded, title: "MAP\nVIEW", isEnabled: false),
      ToolItem(
        icon: Icons.upload_rounded,
        title: "PUBLISH\nMESSAGE",
        isEnabled: false,
      ),
      ToolItem(
        icon: Icons.power_settings_new_rounded,
        title: "DISCONNECT",
        isDanger: true,
        onTap: () => _navigateToDisconnect(context),
      ),
    ];
  }

  // ─── CONTROL ROBOT — avec sélection de mission obligatoire ────────────────
  static Future<void> _navigateToControl(BuildContext context) async {
    final state = MissionState.instance;

    // ✅ Si une mission de session existe déjà → y aller directement
    if (state.sessionMission != null) {
      Navigator.push(
        context,
        _createFadeRoute(ControlRobotWrapper(mission: state.sessionMission!)),
      );
      return;
    }

    // Charger les missions si nécessaire
    if (state.missions.isEmpty && !state.loading) {
      await state.loadMissions();
    }
    if (!context.mounted) return;

    // Afficher le popup de sélection
    final mission = await showMissionSelectDialog(context);
    if (mission == null || !context.mounted) return;

    // ✅ Mémoriser la mission de session
    state.setSessionMission(mission);

    Navigator.push(
      context,
      _createFadeRoute(ControlRobotWrapper(mission: mission)),
    );
  }

  // ─── MISSION ──────────────────────────────────────────────────────────────
  static void _navigateToMission(BuildContext context) {
    Navigator.push(context, _createFadeRoute(const MissionListPage()));
  }

  // ─── SENSOR MONITOR ───────────────────────────────────────────────────────
  static void _navigateToSensor(BuildContext context) {
    Navigator.push(context, _createFadeRoute(const SensorMonitorPage()));
  }

  // ─── DISCONNECT ───────────────────────────────────────────────────────────
  static void _navigateToDisconnect(BuildContext context) {
    Navigator.push(context, _createDissolveRoute(const DisconnectAnimationPage()));
  }

  // ─── Transitions ──────────────────────────────────────────────────────────

  static Route _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  static Route _createDissolveRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
                ),
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.06).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeIn),
                ),
                child: Container(),
              ),
            ),
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: child,
            ),
          ],
        );
      },
    );
  }
}