import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryVariant = Color(0xFF8B7AB8);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color accent = Color(0xFFFFB74D);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Note Colors (for custom note coloring)
  static const List<Color> noteColors = [
    Color(0xFFFFFFFF), // White (default)
    Color(0xFFFFE4E1), // Misty Rose
    Color(0xFFFFEBCD), // Blanched Almond
    Color(0xFFFFF8DC), // Cornsilk
    Color(0xFFE0FFE0), // Light Green
    Color(0xFFE0F7FA), // Light Cyan
    Color(0xFFE1F5FE), // Light Blue
    Color(0xFFE8EAF6), // Light Indigo
    Color(0xFFF3E5F5), // Light Purple
    Color(0xFFFCE4EC), // Light Pink
  ];

  static const List<Color> noteColorsDark = [
    Color(0xFF2C2C2C), // Dark Gray (default)
    Color(0xFF4A3835), // Dark Rose
    Color(0xFF4A4235), // Dark Almond
    Color(0xFF4A4635), // Dark Yellow
    Color(0xFF354A35), // Dark Green
    Color(0xFF354546), // Dark Cyan
    Color(0xFF353D4A), // Dark Blue
    Color(0xFF3A3D4A), // Dark Indigo
    Color(0xFF4A3D4A), // Dark Purple
    Color(0xFF4A3540), // Dark Pink
  ];

  // Utility Colors
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
}