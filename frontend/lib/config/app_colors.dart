import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlack = Color(0xFF0A0408);
  static const Color primaryRed = Color(0xFFE42B38);
  static const Color wineRed = Color(0xFFAA1330);
  static const Color navyBlue = Color(0xFF00045B);
  static const Color cyan = Color(0xFF12D4EF);
  
  // Gradient Colors
  static const Color lavender = Color(0xFFE2A8FE);
  static const Color purple = Color(0xFFAF77D5);
  static const Color deepViolet = Color(0xFF7E4EAC);
  static const Color royalPurple = Color(0xFF532D84);
  static const Color indigo = Color(0xFF2E165B);
  static const Color darkViolet = Color(0xFF120632);
  static const Color nearBlack = Color(0xFF02000A);
  
  // Utility Colors
  static const Color lightGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF2A2A2A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lavender, purple, deepViolet, royalPurple, indigo, darkViolet],
  );
  
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, purple, primaryRed],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlack, nearBlack],
  );
  
  static const LinearGradient categoryGradient1 = LinearGradient(
    colors: [primaryRed, wineRed],
  );
  
  static const LinearGradient categoryGradient2 = LinearGradient(
    colors: [cyan, navyBlue],
  );
  
  static const LinearGradient categoryGradient3 = LinearGradient(
    colors: [lavender, purple],
  );
  
  static const LinearGradient categoryGradient4 = LinearGradient(
    colors: [deepViolet, royalPurple],
  );
}
