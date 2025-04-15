import 'package:flutter/material.dart';

class MoodItem {
  final String name;
  final String description;
  final Color color;
  final IconData icon;

  const MoodItem({
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });
}
