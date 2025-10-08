import 'package:flutter/material.dart';

class WebbUIBottomNavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const WebbUIBottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
