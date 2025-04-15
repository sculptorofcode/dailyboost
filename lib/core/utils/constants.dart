import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'DailyBoost';
  static const double basePadding = 16.0;
  static const double baseRadius = 16.0; // Increased radius for modern look

  // Animation durations
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration standardAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Light Theme Colors - New vibrant palette
  static const Color primaryColor = Color(0xFF4E55FD); // Vibrant blue
  static const Color accentColor = Color(0xFFFF6B6B); // Coral red
  static const Color tertiaryColor = Color(0xFF4ECCA3); // Mint green
  static const Color lightScaffoldBg = Color(
    0xFFF9F9FE,
  ); // Clean white with slight blue tint
  static const Color textColor = Color(0xFF2D3250); // Deep slate blue
  static const Color cardColor = Color(0xFFFFFFFF); // Pure white
  static const Color shadowColor = Color(0x1A000000); // Light shadow

  // Gradient colors
  static const List<Color> lightGradient = [
    Color(0xFF4E55FD),
    Color(0xFF8A94FF),
  ];
  static const List<Color> accentGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFF9D9D),
  ];

  // Dark Theme Colors - Refined dark palette
  static const Color primaryColorDark = Color(
    0xFF7C84FF,
  ); // Lighter vibrant blue
  static const Color accentColorDark = Color(0xFFFF8080); // Lighter coral
  static const Color tertiaryColorDark = Color(0xFF5DEEB2); // Lighter mint
  static const Color darkScaffoldBg = Color(0xFF1A1B2E); // Very dark blue
  static const Color textColorDark = Color(
    0xFFE4E6F5,
  ); // Off-white with blue tint
  static const Color cardColorDark = Color(0xFF2D3250); // Dark slate blue
  static const Color shadowColorDark = Color(0x40000000); // Darker shadow

  // Gradient colors for dark theme
  static const List<Color> darkGradient = [
    Color(0xFF404575),
    Color(0xFF2D3250),
  ];
  static const List<Color> darkAccentGradient = [
    Color(0xFFFF8080),
    Color(0xFFC55F5F),
  ];
}
