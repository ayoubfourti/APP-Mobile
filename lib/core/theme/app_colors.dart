import 'package:flutter/material.dart';

/// Couleurs de l'application centralisées
class AppColors {
  // Couleurs de fond
  static const Color background = Color(0xFF0A0E27);
  static const Color darkBlue = Color(0xFF0A0E27);
  static const Color navyBlue = Color(0xFF1A1A2E);
  static const Color mediumBlue = Color(0xFF16213E);
  static const Color accentBlue = Color(0xFF0F3460);
  
  // Couleur primaire (cyan)
  static const Color cyan = Color(0xFF00F5FF);
  static const Color primaryCyan = Color(0xFF00F5FF);
  
  // Couleurs d'état
  static const Color green = Color(0xFF00FF00);
  static const Color red = Color(0xFFFF6B6B);
  static const Color orange = Color(0xFFFFAA00);
  static const Color purple = Color(0xFFAA00FF);
  static const Color yellow = Color(0xFFFFFF00);
  
  // Couleurs de statut
  static const Color statusGrey = Color(0xFF888888);
  static const Color statusGreen = Color(0xFF00FF00);
  static const Color statusRed = Color(0xFFFF6B6B);
  static const Color statusOrange = Color(0xFFFFAA00);
  
  // Couleurs supplémentaires
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  
  // Gradient backgrounds
  static const List<Color> techGradient = [
    darkBlue,
    navyBlue,
    mediumBlue,
    accentBlue,
  ];
  
  // Helpers pour opacité
  static Color cyanWith(double opacity) => cyan.withOpacity(opacity);
  static Color backgroundWith(double opacity) => background.withOpacity(opacity);
  static Color whiteWith(double opacity) => white.withOpacity(opacity);
  static Color greyWith(double opacity) => statusGrey.withOpacity(opacity);
}