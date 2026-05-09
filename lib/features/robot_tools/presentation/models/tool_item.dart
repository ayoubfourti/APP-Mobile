import 'package:flutter/material.dart';

/// Modèle représentant un outil dans le dashboard
class ToolItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDanger;
  final bool isEnabled;

  const ToolItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.isDanger = false,
    this.isEnabled = true,
  });
}