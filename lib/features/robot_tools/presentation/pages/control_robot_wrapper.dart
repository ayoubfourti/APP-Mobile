// lib/features/robot_tools/presentation/pages/control_robot_wrapper.dart

import 'package:flutter/material.dart';
import '../../../mission/presentation/models/mission_model.dart';
import '../../../mission/presentation/widget/mission_end_dialog.dart';
import '../../../robot_control/presentation/page/control_robot_page.dart';
import '../../../../core/config/api_config.dart';

class ControlRobotWrapper extends StatelessWidget {
  final MissionModel mission;

  const ControlRobotWrapper({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack(context);
      },
      child: ControlRobotPage(
        cameraStreamUrl: ApiConfig.cameraStreamUrl,
      ),
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    final ended = await showMissionEndDialog(context, mission);
    if (!context.mounted) return;
    Navigator.pop(context, ended);
  }
}